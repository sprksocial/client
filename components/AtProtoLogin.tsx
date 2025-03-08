import React, { useState } from 'react'
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator, Alert } from 'react-native'
import useAtProto from '../hooks/useAtProto'

/**
 * A simple login component for AT Protocol authentication
 */
export const AtProtoLogin: React.FC = () => {
  const [identifier, setIdentifier] = useState('')
  const [password, setPassword] = useState('')
  const [isEmailLogin, setIsEmailLogin] = useState(false)
  const { login, loginWithEmail, loading, error, isLoggedIn, session, logout } = useAtProto()

  const handleLogin = async () => {
    if (!identifier || !password) {
      Alert.alert('Error', 'Please enter both username/email and password')
      return
    }

    try {
      if (isEmailLogin) {
        await loginWithEmail(identifier, password)
      } else {
        await login(identifier, password)
      }
      // Clear inputs on success
      setIdentifier('')
      setPassword('')
    } catch (err) {
      // Error is already handled by the hook
      console.error('Login error:', err)
    }
  }

  const handleLogout = () => {
    logout()
  }

  const toggleLoginMethod = () => {
    setIsEmailLogin(!isEmailLogin)
    setIdentifier('')
  }

  if (isLoggedIn && session) {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Logged In</Text>
        <Text style={styles.userInfo}>Handle: {session.handle}</Text>
        <Text style={styles.userInfo}>DID: {session.did}</Text>
        {session.email && <Text style={styles.userInfo}>Email: {session.email}</Text>}

        <TouchableOpacity style={styles.button} onPress={handleLogout}>
          <Text style={styles.buttonText}>Logout</Text>
        </TouchableOpacity>
      </View>
    )
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>
        {isEmailLogin ? 'Login with Email' : 'Login with Handle'}
      </Text>

      <TouchableOpacity
        style={styles.toggleButton}
        onPress={toggleLoginMethod}
      >
        <Text style={styles.toggleText}>
          {isEmailLogin
            ? 'Switch to handle login'
            : 'Switch to email login'}
        </Text>
      </TouchableOpacity>

      <TextInput
        style={styles.input}
        placeholder={isEmailLogin ? "Email" : "Handle (e.g., user.bsky.social)"}
        value={identifier}
        onChangeText={setIdentifier}
        autoCapitalize="none"
        keyboardType={isEmailLogin ? "email-address" : "default"}
      />

      <TextInput
        style={styles.input}
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />

      {error && (
        <Text style={styles.errorText}>
          {error.message || 'Login failed. Please try again.'}
        </Text>
      )}

      <TouchableOpacity
        style={[styles.button, loading && styles.buttonDisabled]}
        onPress={handleLogin}
        disabled={loading}
      >
        {loading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Login</Text>
        )}
      </TouchableOpacity>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    padding: 20,
    backgroundColor: '#fff',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
    width: '100%',
    maxWidth: 400,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
    fontSize: 16,
  },
  button: {
    backgroundColor: '#3498db',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonDisabled: {
    backgroundColor: '#95a5a6',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  errorText: {
    color: '#e74c3c',
    marginBottom: 10,
  },
  toggleButton: {
    marginBottom: 15,
    alignSelf: 'center',
  },
  toggleText: {
    color: '#3498db',
    fontSize: 14,
  },
  userInfo: {
    fontSize: 16,
    marginBottom: 10,
    fontFamily: 'monospace',
  },
})

export default AtProtoLogin