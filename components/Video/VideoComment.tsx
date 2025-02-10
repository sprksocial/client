// VideoComment.tsx
import React from 'react';
import { StyleSheet, View, Image, TouchableOpacity, useColorScheme } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';
import { VideoCommentProps } from '@/types/Interfaces';

const VideoComment: React.FC<VideoCommentProps> = ({
    id,
    author,
    content,
    likes,
    commentReplies = [],
    onLike,
    onReply,
}) => {
    const colorScheme = useColorScheme()

    const styles = StyleSheet.create({
        comment: {
            backgroundColor: '#fafafa',
            paddingVertical: 5,
            flexDirection: 'row',
            borderBottomColor: '#e0e0e0',
            borderBottomWidth: 1,
        },
        commentHeader: {
            flexDirection: 'row',
            alignItems: 'center',
            paddingHorizontal: 5,
            gap: 2,
        },
        profilePicture: {
            width: 20,
            height: 20,
            borderRadius: 15,
            overflow: 'hidden',
            marginRight: 2,
        },
        profilePictureImage: {
            width: '100%',
            height: '100%',
            borderRadius: 15,
        },
        commentContent: {
            paddingHorizontal: 10,
        },
        commentLeftSide: {
            flex: 1,
            marginLeft: 5,
        },
        commentRightSide: {
            width: 50,
            alignItems: 'center',
            justifyContent: 'flex-start',
        },
        iconContainer: {
            alignItems: 'center',
        },
        likesText: {
            color: '#9a9a9a',
            fontSize: 12,
            marginTop: 2,
        },
        nameText: {
            maxWidth: 120,
        },
        separator: {
            marginHorizontal: 1,
        },
        usernameText: {
            maxWidth: 150,
        },
        commentFooter: {
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'flex-start',
            gap: 10,
        },
        commentTime: {
            color: '#9a9a9a',
        },
        replyText: {
            color: '#9a9a9a',
            fontWeight: 'bold',
        },
    
    });
    return (
        <View style={styles.comment}>
            <View style={styles.commentLeftSide}>
                <View style={styles.commentHeader}>
                    <View style={styles.profilePicture}>
                        <Image
                            source={{ uri: author.image }}
                            style={styles.profilePictureImage}
                        />
                    </View>
                    <ThemedText
                        type='name'
                        lightColor={Colors.light.text}
                        darkColor={Colors.light.text}
                        style={styles.nameText}
                        numberOfLines={1}
                        ellipsizeMode='tail'
                    >
                        {author.name}
                    </ThemedText>
                    <ThemedText
                        type='username'
                        lightColor={Colors.light.text}
                        darkColor={Colors.light.text}
                        style={styles.separator}
                        numberOfLines={1}
                    >
                        •
                    </ThemedText>
                    <ThemedText
                        type='username'
                        lightColor={Colors.dark.text}
                        darkColor={Colors.light.text}
                        style={styles.usernameText}
                        numberOfLines={1}
                        ellipsizeMode='tail'
                    >
                        @{author.handler}
                    </ThemedText>
                </View>
                <View style={styles.commentContent}>
                    <ThemedText
                        type='comment'
                        lightColor={Colors.light.text}
                        darkColor={Colors.light.text}
                    >
                        {content}
                    </ThemedText>
                    <View style={styles.commentFooter}>
                        <ThemedText
                            type='subtitle'
                            lightColor={Colors.dark.text}
                            darkColor={Colors.light.text}
                            style={styles.commentTime}
                        >
                            1h
                        </ThemedText>
                        <TouchableOpacity>
                        <ThemedText
                            type='subtitle'
                            lightColor={Colors.dark.tint}
                            darkColor={Colors.light.tint}
                            style={styles.replyText}
                        >
                            Reply
                        </ThemedText>
                        </TouchableOpacity>
                    </View>
                    {commentReplies.length > 0 && (
                        <TouchableOpacity>
                            <View style={styles.commentFooter}>
                            <ThemedText
                                type='subtitle'
                                lightColor={Colors.dark.text}
                                darkColor={Colors.light.text}
                                style={styles.commentTime}
                            >
                                {commentReplies.length} replies <Ionicons name="chevron-down" size={12} />
                            </ThemedText>
                        </View>
                        </TouchableOpacity>
                        )}
                </View>
            </View>
            <View style={styles.commentRightSide}>
                <TouchableOpacity style={styles.iconContainer} onPress={onLike}>
                    <Ionicons color="#9a9a9a" name="heart" size={25} />
                    <ThemedText
                        type="name"
                        style={styles.likesText}
                        lightColor={Colors.light.text}
                        darkColor={Colors.dark.text}
                    >
                        {likes}
                    </ThemedText>
                </TouchableOpacity>
            </View>
        </View>
    );
};



export default VideoComment;
