import React from 'react';
import { View, StyleSheet } from 'react-native';
import ActionButton from '@/components/global/ActionButton';

interface ProfileActionButtonsProps {
  isLoggedIn: boolean;
  isMine: boolean;
  onRegister: () => void;
  onLogin: () => void;
  onFollow: () => void;
  onLogout: () => void;
  onEdit?: () => void;
  onShareProfile?: () => void;
  onFriends?: () => void;
}

const ProfileActionButtons = ({
  isLoggedIn,
  isMine,
  onRegister,
  onLogin,
  onFollow,
  onLogout,
  onEdit = () => {},
  onShareProfile = () => {},
  onFriends = () => {}
}: ProfileActionButtonsProps) => {
  
  if (!isLoggedIn && isMine) {
    return (
      <View style={styles.profileActionButtonsVertical}>
        <ActionButton
          type="primary"
          title="Registrar"
          onPress={onRegister}
          width="60%"
        />
        <ActionButton
          type="outline"
          title="Login"
          onPress={onLogin}
          width="60%"
        />
      </View>
    );
  }

  if (!isLoggedIn && !isMine) {
    return (
      <ActionButton
        type="primary"
        title="Follow"
        onPress={onLogin}
        width={250}
      />
    );
  }

  if (isLoggedIn && !isMine) {
    return (
      <ActionButton
        type="primary"
        title="Follow"
        onPress={onFollow}
        width={250}
      />
    );
  }

  if (isLoggedIn && isMine) {
    return (
      <View style={styles.profileActionButtons}>
        <ActionButton
          type="primary"
          title="Edit"
          onPress={onEdit}
          width="30%"
        />
        <ActionButton
          type="outline"
          title="Share Profile"
          onPress={onShareProfile}
          width="45%"
        />
        <ActionButton
          type="outline"
          title="Friends +"
          onPress={onFriends}
          width="25%"
        />
      </View>
    );
  }

  return null;
};

const styles = StyleSheet.create({
  profileActionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 10,
    width: '100%',
    marginTop: 15,
  },
  profileActionButtonsVertical: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: 10,
    width: '100%',
  },
});

export default ProfileActionButtons; 