import { useState, useEffect, useCallback } from 'react'
import {
  pdsLogin,
  pdsLogout,
  getCurrentSession,
  getAgent,
  isLoggedIn
} from '../api/pdsAuth'
import sessionManager, { SessionEventType } from '../api/sessionManager'
import { Agent } from '@atproto/api'

/**
 * A React hook for accessing AT Protocol authentication
 * Provides login, logout, and session state
 */
export const useAtProto = () => {
  const [session, setSession] = useState<any>(getCurrentSession())
  const [agent, setAgent] = useState<Agent | null>(getAgent())
  const [loading, setLoading] = useState<boolean>(false)
  const [error, setError] = useState<Error | null>(null)

  // Update state when session changes
  useEffect(() => {
    // Set initial state
    setSession(getCurrentSession())
    setAgent(getAgent())

    // Listen for session events
    const handleSessionCreate = (data: any) => {
      setSession(data)
      setAgent(getAgent())
      setError(null)
    }

    const handleSessionRefresh = (data: any) => {
      setSession(data)
    }

    const handleSessionExpiredOrDeleted = () => {
      setSession(null)
      setAgent(null)
    }

    // Add event listeners
    sessionManager.on(SessionEventType.CREATE, handleSessionCreate)
    sessionManager.on(SessionEventType.REFRESH, handleSessionRefresh)
    sessionManager.on(SessionEventType.EXPIRED, handleSessionExpiredOrDeleted)
    sessionManager.on(SessionEventType.DELETE, handleSessionExpiredOrDeleted)

    // Cleanup
    return () => {
      sessionManager.off(SessionEventType.CREATE, handleSessionCreate)
      sessionManager.off(SessionEventType.REFRESH, handleSessionRefresh)
      sessionManager.off(SessionEventType.EXPIRED, handleSessionExpiredOrDeleted)
      sessionManager.off(SessionEventType.DELETE, handleSessionExpiredOrDeleted)
    }
  }, [])

  // Login with handle
  const login = useCallback(async (handle: string, password: string) => {
    setLoading(true)
    setError(null)

    try {
      const result = await pdsLogin(handle, password)
      return result
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Login failed'))
      throw err
    } finally {
      setLoading(false)
    }
  }, [])

  // Logout
  const logout = useCallback(() => {
    pdsLogout()
  }, [])

  return {
    // State
    session,
    agent,
    loading,
    error,
    isLoggedIn: !!session,

    // Methods
    login,
    logout,
  }
}

export default useAtProto