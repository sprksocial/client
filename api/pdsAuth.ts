import { PROD_PDS } from "@/constants/atproto";
import { createSimpleDIDResolver } from "./simpleDIDResolver";
import sessionManager from "./sessionManager";
import { Agent, CredentialSession } from "@atproto/api";

// Create the resolver once at module level
const resolver = createSimpleDIDResolver();

/**
 * Login to an AT Protocol PDS (Personal Data Server) using a handle and password
 *
 * @param handle - The user handle (e.g., username.bsky.social)
 * @param password - The user's password
 * @returns The session data object or null if login failed
 */
export const pdsLogin = async (handle: string, password: string) => {
  try {
    const resolverAgent = new Agent(new URL(PROD_PDS));
    const handleRes = await resolverAgent.resolveHandle({
      handle: handle,
    });

    if (!handleRes.success) {
      throw new Error("Handle not found");
    }

    // Use the new resolver to get the DID doc
    const didDoc = await resolver.resolveHandleToDidDoc(handle);

    // Get the PDS URL from the DID document service endpoints
    const pdsUrl = didDoc.pds;

    if (!pdsUrl) {
      throw new Error("Could not find PDS URL for this account");
    }

    const pdsCredentialSession = new CredentialSession(new URL(pdsUrl));

    const agent = new Agent(pdsCredentialSession);

    const { success, data } = await agent.com.atproto.server.createSession({
      identifier: handle,
      password,
    });

    if (!success) {
      throw new Error("Login was not successful");
    }

    const session = {
      ...data,
      active: data.active ?? false,
    };

    await sessionManager.setSession(agent, session);

    return data;
  } catch (error) {
    console.error("Login failed:", error);
    throw error;
  }
};

export const pdsRegister = async (
  email: string,
  handle: string,
  password: string,
  inviteCode?: string
) => {
  try {
    const cred = new CredentialSession(new URL(PROD_PDS));

    const agent = new Agent(cred);

    const { success, data } = await agent.com.atproto.server.createAccount({
      email,
      handle,
      password,
      inviteCode,
    });

    if (!success) {
      throw new Error("Register was not successful");
    }

    const session = {
      ...data,
      active: true,
    };

    await sessionManager.setSession(agent, session);
  } catch (error) {
    console.error("Register failed:", error);
    throw error;
  }
};

/**
 * Logout the current user
 */
export const pdsLogout = async () => {
  await sessionManager.clearSession();
};

/**
 * Get the current session if available
 */
export const getCurrentSession = () => {
  return sessionManager.getSession();
};

/**
 * Get the current agent if logged in
 */
export const getAgent = () => {
  return sessionManager.getAgent();
};

/**
 * Check if user is currently logged in
 */
export const isLoggedIn = () => {
  return sessionManager.isLoggedIn();
};
