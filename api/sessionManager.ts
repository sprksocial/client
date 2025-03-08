import EventEmitter from "events";
import { Agent, AtpSessionData, CredentialSession } from "@atproto/api";
import * as SecureStore from 'expo-secure-store';

export enum SessionEventType {
  CREATE = "session:create",
  REFRESH = "session:refresh",
  EXPIRED = "session:expired",
  DELETE = "session:delete",
}

/**
 * SessionManager handles storing and managing AT Protocol sessions
 * It maintains the session data globally and emits events when the session changes
 */
class SessionManager extends EventEmitter {
  private agent: Agent | null = null;
  private sessionData: AtpSessionData | null = null;
  private refreshTimeout: NodeJS.Timeout | null = null;
  private persistKey: string = "atproto_session";
  private pdsUrl: string = "";

  constructor() {
    super();
    // Immediately invoke an async function to handle async initialization
    (async () => {
      await this.loadSession();
    })().catch(error => {
      console.error('Failed to load session during initialization:', error);
    });
  }

  /**
   * Get the current Agent instance
   */
  getAgent() {
    return this.agent;
  }

  /**
   * Get the current session data
   */
  getSession() {
    return this.sessionData;
  }

  /**
   * Store a new session
   */
  async setSession(agent: Agent, session: AtpSessionData): Promise<void> {
    this.agent = agent;
    this.sessionData = session;
    this.pdsUrl = session.accessJwt
      ? JSON.parse(atob(session.accessJwt.split(".")[1])).aud.replace(
          "did:web:",
          ""
        )
      : "";
    await this.persistSession();
    // this.scheduleRefresh();
    this.emit(SessionEventType.CREATE, session);
  }

  // /**
  //  * Refresh the current session
  //  */
  // async refreshSession(): Promise<any> {
  //   if (!this.agent || !this.sessionData) {
  //     return null;
  //   }

  //   try {
  //     // For refreshing with the Agent class
  //     if (this.sessionData.refreshJwt) {
  //       // Use the refresh method if available
  //       if (typeof this.agent.refreshSession === "function") {
  //         const result = await this.agent.refreshSession();
  //         if (result && result.data) {
  //           this.sessionData = result.data;
  //           this.persistSession();
  //           this.scheduleRefresh();
  //           this.emit(SessionEventType.REFRESH, result.data);
  //           return result.data;
  //         }
  //       } else {
  //         const cred = new CredentialSession(new URL(this.sessionData.pds));
  //       }
  //     }

  //     // If refresh failed or isn't available
  //     this.clearSession();
  //     this.emit(SessionEventType.EXPIRED);
  //     return null;
  //   } catch (error) {
  //     console.error("Failed to refresh session:", error);
  //     this.clearSession();
  //     this.emit(SessionEventType.EXPIRED);
  //     return null;
  //   }
  // }

  /**
   * Clear the current session (logout)
   */
  async clearSession(): Promise<void> {
    if (this.refreshTimeout) {
      clearTimeout(this.refreshTimeout);
      this.refreshTimeout = null;
    }

    this.agent = null;
    this.sessionData = null;
    this.pdsUrl = "";
    await this.removePersistedSession();
    this.emit(SessionEventType.DELETE);
  }

  /**
   * Check if a user is currently logged in
   */
  isLoggedIn(): boolean {
    return !!this.sessionData && !!this.agent;
  }

  /**
   * Schedule a session refresh before it expires
   */
  // private scheduleRefresh(): void {
  //   if (this.refreshTimeout) {
  //     clearTimeout(this.refreshTimeout);
  //   }

  //   // If no session, don't schedule refresh
  //   if (!this.sessionData) return;

  //   // Default refresh time - 30 minutes before expiry
  //   // Since we don't have a specific expiry time from the session,
  //   // we'll use a conservative 23.5 hour refresh interval by default
  //   const refreshInterval = 23.5 * 60 * 60 * 1000; // 23.5 hours

  //   // Schedule refresh
  //   this.refreshTimeout = setTimeout(
  //     () => this.refreshSession(),
  //     refreshInterval
  //   );
  // }

  /**
   * Persist session to storage using SecureStore
   */
  private async persistSession(): Promise<void> {
    if (this.sessionData) {
      try {
        await SecureStore.setItemAsync(
          this.persistKey,
          JSON.stringify(this.sessionData)
        );
      } catch (error) {
        console.error('Error saving session to SecureStore:', error);
      }
    }
  }

  /**
   * Remove persisted session from SecureStore
   */
  private async removePersistedSession(): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(this.persistKey);
    } catch (error) {
      console.error('Error removing session from SecureStore:', error);
    }
  }

  /**
   * Load session from SecureStore on startup
   */
  private async loadSession(): Promise<void> {
    try {
      const savedSession = await SecureStore.getItemAsync(this.persistKey);

      if (savedSession) {
        this.sessionData = JSON.parse(savedSession);

        // Create a new agent with the saved data
        if (this.sessionData && this.sessionData.did) {
          // Extract the PDS URL from the access token
          this.pdsUrl = this.sessionData.accessJwt
            ? JSON.parse(atob(this.sessionData.accessJwt.split(".")[1])).aud.replace(
                "did:web:",
                ""
              )
            : "";

          if (!this.pdsUrl) {
            throw new Error("Could not find PDS URL for this account");
          }
          const cred = new CredentialSession(new URL(`https://${this.pdsUrl}`));
          cred.resumeSession(this.sessionData);

          const agent = new Agent(cred);

          // Restore the session
          this.agent = agent;
          // this.scheduleRefresh();
        }
      }
    } catch (error) {
      console.error('Error loading session from SecureStore:', error);
      // Clear any invalid or corrupted session data
      this.removePersistedSession();
    }
  }
}

// Create a singleton instance
export const sessionManager = new SessionManager();
export default sessionManager;
