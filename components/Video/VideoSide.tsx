// src/components/Video/VideoSide.tsx

import React from 'react';
import { View, Image, TouchableOpacity, StyleSheet, useColorScheme } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';
import { VideoSideProps } from '@/types/Interfaces';

const VideoSide: React.FC<VideoSideProps> = ({ videoData, onComments }) => {
      const colorScheme = useColorScheme();

    const styles = StyleSheet.create({
        container: {
            alignItems: 'flex-end',
            justifyContent: 'center',
            width: '15%',
        },
        buttonsList: {
            alignItems: 'center',
            justifyContent: 'center',
            flexDirection: 'column',
        },
        profilePicWrapper: {
            width: 50,
            height: 50,
            borderRadius: 25,
            marginBottom: 20,
            shadowColor: '#000',
            shadowOffset: { width: 0, height: 0 },
            shadowOpacity: 0.5,
            shadowRadius: 5,
            elevation: 5,
        },
        profilePic: {
            width: '100%',
            height: '100%',
            borderRadius: 25,
        },
        iconContainer: {
            alignItems: 'center',
            marginVertical: 8,
        },
        icon: {
            textShadowColor: 'rgba(0, 0, 0, 0.5)',
            textShadowOffset: { width: 0, height: 0 },
            textShadowRadius: 5,
        },
        text: {
            textShadowColor: 'rgba(0, 0, 0, 1)',
            textShadowOffset: { width: 0, height: 0 },
            textShadowRadius: 5,
        },
        addIcon: {
            position: 'relative',
            bottom: 0,
            left: 0,
            width: 30,
        },
    });

    return (
        <View style={styles.container} pointerEvents="box-none">
            <View style={styles.buttonsList}>
                <TouchableOpacity style={styles.iconContainer}>
                    <View style={styles.profilePicWrapper}>
                        <Image
                            source={{ uri: videoData.creator?.image || '' }}
                            style={styles.profilePic}
                        />
                    </View>
                    <TouchableOpacity onPress={() => console.log('followed')} style={styles.addIcon}>
                        <Ionicons color={Colors[colorScheme ?? 'light'].tint} name="add-circle-sharp" size={30} style={{ position: 'absolute', bottom: 0, left: 0 }} />
                        <Ionicons color="#FFFFFF" name="add-circle-outline" size={30} style={{ position: 'absolute', bottom: 0, left: 0 }} />
                    </TouchableOpacity>
                </TouchableOpacity>

                <TouchableOpacity style={styles.iconContainer} onPress={() => console.log('Liked video')}>
                    <Ionicons style={styles.icon} color="white" name="heart-outline" size={30} />
                    <ThemedText
                        type="defaultBold"
                        style={styles.text}
                        lightColor={Colors.dark.text}
                        darkColor={Colors.dark.text}
                    >
                        {videoData.likes?.amount ?? 0}
                    </ThemedText>
                </TouchableOpacity>

                <TouchableOpacity style={styles.iconContainer} onPress={onComments}>
                    <Ionicons style={styles.icon} color="white" name="chatbubble-outline" size={30} />
                    <ThemedText
                        type="defaultBold"
                        style={styles.text}
                        lightColor={Colors.dark.text}
                        darkColor={Colors.dark.text}
                    >
                        {videoData.comments?.length ?? 0}
                    </ThemedText>
                </TouchableOpacity>

                <TouchableOpacity style={styles.iconContainer} onPress={() => console.log('Shared video')}>
                    <Ionicons style={styles.icon} color="white" name="share-social-outline" size={30} />
                    <ThemedText
                        type="defaultBold"
                        style={styles.text}
                        lightColor={Colors.dark.text}
                        darkColor={Colors.dark.text}
                    >
                        {videoData.shares}
                    </ThemedText>
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default VideoSide;
