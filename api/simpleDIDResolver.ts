import { Agent } from "@atproto/api";
import { AtprotoData } from "@atproto/identity";
import sessionManager from "./sessionManager";
import { PROD_PDS } from "@/constants/atproto";

// Interface for BidirectionalResolver to avoid circular imports
export interface DIDResolver {
  resolveDidToHandle(did: string): Promise<string>;
  resolveHandleToDidDoc(handle: string): Promise<AtprotoData>;
  resolveDidsToHandles(dids: string[]): Promise<Record<string, string>>;
}

// Cache durations
const ONE_HOUR = 60 * 60 * 1000;
const ONE_DAY = ONE_HOUR * 24;

// Simple implementation of caches with expiration
class SimpleCache<T> {
  private cache = new Map<string, { value: T; expiry: number }>();
  private ttl: number;

  constructor(ttlMs: number) {
    this.ttl = ttlMs;
  }

  get(key: string): T | undefined {
    const item = this.cache.get(key);
    if (!item) return undefined;

    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return undefined;
    }

    return item.value;
  }

  set(key: string, value: T): void {
    this.cache.set(key, {
      value,
      expiry: Date.now() + this.ttl,
    });
  }

  delete(key: string): void {
    this.cache.delete(key);
  }
}

/**
 * Create a simple DID resolver with caching that implements DIDResolver
 */
export function createSimpleDIDResolver(): DIDResolver {
  // Create caches
  const didDocCache = new SimpleCache<AtprotoData>(ONE_HOUR);
  const handleToDIDCache = new SimpleCache<string>(ONE_DAY);
  const didToHandleCache = new SimpleCache<string>(ONE_DAY);

  // Helper function to get agent or create a new one
  const getAgent = () => {
    const agent = sessionManager.getAgent();
    if (agent) return agent;
    return new Agent(new URL(PROD_PDS));
  };

  // Helper function to resolve DID document (not exposed in interface)
  const resolveDidDocHelper = async (did: string): Promise<AtprotoData> => {
    // Check cache first
    const cachedDoc = didDocCache.get(did);
    if (cachedDoc) return cachedDoc;

    try {
      // Get agent
      const agent = getAgent();

      // Use plc.directory as fallback
      const didResponse = await fetch(`https://plc.directory/${did}`);

      if (!didResponse.ok) {
        throw new Error(`Failed to resolve DID document for ${did}`);
      }

      const didData = await didResponse.json();
      const atprotoData: AtprotoData = {
        did: didData.did,
        handle: didData.alsoKnownAs?.[0]?.replace('at://', '') || did,
        pds: didData.service?.find((s: any) => s.id === '#atproto_pds')?.serviceEndpoint || '',
        signingKey: didData.verificationMethod?.[0]?.publicKeyMultibase || '',
      };

      // Cache the document
      didDocCache.set(did, atprotoData);

      return atprotoData;
    } catch (error) {
      console.error("Error resolving DID document:", error);
      throw error;
    }
  };

  // The object that implements DIDResolver
  return {
    /**
     * Resolve a DID to a handle with caching
     */
    async resolveDidToHandle(did: string): Promise<string> {
      // Check cache first
      const cachedHandle = didToHandleCache.get(did);
      if (cachedHandle) return cachedHandle;

      try {
        // Resolve DID document using helper function
        const didDoc = await resolveDidDocHelper(did);

        // Cache the handle
        if (didDoc.handle) {
          didToHandleCache.set(did, didDoc.handle);
          return didDoc.handle;
        }

        return did; // Fallback to DID if no handle
      } catch (error) {
        console.error("Error resolving DID to handle:", error);
        return did; // Return the DID as fallback
      }
    },

    /**
     * Resolve a handle to a DID document with caching
     */
    async resolveHandleToDidDoc(handle: string): Promise<AtprotoData> {
      try {
        // Check if we already have the DID in cache
        const cachedDid = handleToDIDCache.get(handle);
        if (cachedDid) {
          // Check if we have the DID doc cached
          const cachedDoc = didDocCache.get(cachedDid);
          if (cachedDoc) return cachedDoc;
        }

        // Get agent
        const agent = getAgent();

        // Resolve handle to DID
        const didResult = await agent.resolveHandle({ handle });
        const did = didResult.data.did;

        // Cache the handle to DID mapping
        handleToDIDCache.set(handle, did);

        // Then resolve the DID document
        return await resolveDidDocHelper(did);
      } catch (error) {
        console.error("Error resolving handle to DID doc:", error);
        throw new Error(`Failed to resolve handle: ${handle}`);
      }
    },

    /**
     * Resolve multiple DIDs to handles
     */
    async resolveDidsToHandles(dids: string[]): Promise<Record<string, string>> {
      const didHandleMap: Record<string, string> = {};

      // Use Promise.all to resolve all DIDs in parallel
      const resolves = await Promise.all(
        dids.map((did) => this.resolveDidToHandle(did).catch(() => did))
      );

      // Map results to DIDs
      for (let i = 0; i < dids.length; i++) {
        didHandleMap[dids[i]] = resolves[i];
      }

      return didHandleMap;
    }
  };
}