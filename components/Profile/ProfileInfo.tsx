import React from 'react';
import { View, StyleSheet } from 'react-native';
import { UserProps } from '@/types/Interfaces';
import ProfileNumbers from './profileNumbers';
import ProfileName from './ProfileName';
import ProfileHandler from './ProfileHandler';
import ProfilePicture from './ProfilePicture';
import ProfileDescription from './ProfileDescription';

const ProfileInfo: React.FC<{ userData: UserProps }> = ({ userData }) => {
  const styles = StyleSheet.create({
    container: {
      flexDirection: 'column',
      justifyContent: 'center',
      width: '100%',
      padding: 10,
    },
    topContainer: {
      flexDirection: 'row',
      width: '100%',
      alignItems: 'center',
      justifyContent: 'center',
      marginBottom: 10,
    },
    rightContainer: {
      flexDirection: 'column',
      justifyContent: 'center',
      width: 250,
    },
    bottomContainer: {
      width: '100%',
      paddingHorizontal: 20,
    }
  });

  return (
    <View style={styles.container}>
    <View style={styles.topContainer}>
      {userData && <ProfilePicture userData={userData} />}
      <View style={styles.rightContainer}>
        <ProfileName displayName={userData.displayName} />
        {userData.handle === 'null' ? null :
          <ProfileNumbers
            followsCount={userData.followsCount}
            followersCount={userData.followersCount}
            likes={userData.likes}
          />
        }
      </View>

    </View>
    <View style={styles.bottomContainer}>
    <ProfileHandler handle={userData.handle} />
            <ProfileDescription description={userData?.description} />
    </View>
    </View>
  );
};

export default ProfileInfo;
