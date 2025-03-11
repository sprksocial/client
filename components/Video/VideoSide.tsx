import React from 'react';
import { View, Image, TouchableOpacity, StyleSheet, useColorScheme } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';
import { VideoSideProps } from '@/types/Interfaces';
import { navigateToProfile } from '@/app/(tabs)/ProfileScreen';

const VideoSide: React.FC<VideoSideProps> = ({ videoData, onComments }) => {
      const colorScheme = useColorScheme();
      const formatNumber = (num?: number) => {
        if (!num) return '0';
        if (num >= 1_000_000_000) return (num / 1_000_000_000).toFixed(1) + 'B';
        if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + 'M';
        if (num >= 1_000) return (num / 1_000).toFixed(1) + 'K';
        return num.toString();
      };

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
                    <TouchableOpacity 
                        style={styles.profilePicWrapper} 
                        onPress={() => {
                            if (videoData.author?.did) {
                                navigateToProfile(videoData.author.did);
                            }
                        }}
                    >
                        <Image
                            source={{ uri: videoData.author?.avatar || '' }}
                            style={styles.profilePic}
                        />
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => console.log('followed')} style={styles.addIcon}>
                        <Ionicons color={Colors[colorScheme ?? 'light'].tint} name="add-circle-sharp" size={30} style={{ position: 'absolute', bottom: 0, left: 0 }} />
                        <Ionicons color="#FFFFFF" name="add-circle-outline" size={30} style={{ position: 'absolute', bottom: 0, left: 0 }} />
                    </TouchableOpacity>
                </TouchableOpacity>

                <TouchableOpacity style={styles.iconContainer} onPress={() => console.log('Liked video')}>
                    <Ionicons style={styles.icon} color="white" name="heart-outline" size={25} />
                    <ThemedText
                        type="defaultBold"
                        style={styles.text}
                        lightColor={Colors.dark.text}
                        darkColor={Colors.dark.text}
                    >
                        {formatNumber(videoData.likeCount ?? 0)}
                    </ThemedText>
                </TouchableOpacity>

                <TouchableOpacity style={styles.iconContainer} onPress={onComments}>
                    <Ionicons style={styles.icon} color="white" name="chatbubble-outline" size={25} />
                    <ThemedText
                        type="defaultBold"
                        style={styles.text}
                        lightColor={Colors.dark.text}
                        darkColor={Colors.dark.text}
                    >
                        {formatNumber(videoData.replyCount ?? 0)}
                        
                    </ThemedText>
                </TouchableOpacity>

                <TouchableOpacity style={styles.iconContainer} onPress={() => console.log('Shared video')}>
                    <Ionicons style={styles.icon} color="white" name="share-social-outline" size={25} />
                    <ThemedText
                        type="defaultBold"
                        style={styles.text}
                        lightColor={Colors.dark.text}
                        darkColor={Colors.dark.text}
                    >
                        {formatNumber(videoData.repostCount ?? 0)}
                    </ThemedText>
                </TouchableOpacity>
            </View>
        </View>
    );
};

export default VideoSide;
