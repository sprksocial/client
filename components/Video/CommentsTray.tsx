// CommentsTray.tsx
import React from 'react';
import {
    StyleSheet,
    Animated,
    TouchableWithoutFeedback,
    Dimensions,
    View,
    useColorScheme,
    ScrollView,
} from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { Colors } from '@/constants/Colors';
import VideoComment from './VideoComment';
import { VideoCommentProps, CommentsTrayProps } from '@/types/Interfaces';

const { height: screenHeight } = Dimensions.get('window');

const CommentsTray: React.FC<CommentsTrayProps> = ({ visible, onClose, comments }) => {
    const translateY = React.useRef(new Animated.Value(screenHeight)).current;

    const colorScheme = useColorScheme();

    React.useEffect(() => {
        Animated.timing(translateY, {
            toValue: visible ? 0 : screenHeight,
            duration: 300,
            useNativeDriver: true,
        }).start();
    }, [visible, translateY]);

    if (!visible) return null;

    
const styles = StyleSheet.create({
    overlay: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
    },
    tray: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        height: screenHeight * 0.7,
        backgroundColor: '#fafafa',
        borderTopLeftRadius: 20,
        borderTopRightRadius: 20,
        overflow: 'hidden',
    },
    trayContent: {
        flex: 1,
        zIndex: 10,
    },
    trayHeader: {
        fontSize: 18,
        padding: 16,
        fontWeight: 'bold',
        marginBottom: 5,
        textAlign: 'center',
        borderBottomColor: '#ccc',
        borderBottomWidth: 1,
    },
    commentsList: {
        flex: 1,
    },
    noCommentsText: {
        textAlign: 'center',
        marginTop: 16,
    },
});

    return (
        <>
            <TouchableWithoutFeedback onPress={onClose}>
                <View style={styles.overlay} />
            </TouchableWithoutFeedback>
            <Animated.View
                style={[
                    styles.tray,
                    {
                        transform: [{ translateY }],
                    },
                ]}
            >
                <View style={styles.trayContent}>
                    <ThemedText style={styles.trayHeader} lightColor={Colors.dark.tint} darkColor={Colors.light.tint}>
                        Comments
                    </ThemedText>
                    <ScrollView style={styles.commentsList} showsVerticalScrollIndicator={false}>
                        {(comments || []).length > 0 ? (
                            (comments || []).map((comment) => (
                                <VideoComment
                                    id={comment.id}
                                    author={comment.author}
                                    key={comment.id}
                                    content={comment.content}
                                    likes={comment.likes}
                                    commentReplies={comment.commentReplies || []}
                                    onLike={() => {
                                        console.log(`Liked comment ${comment.id}`);
                                    }}
                                />
                            ))
                        ) : (
                            <ThemedText
                                style={styles.noCommentsText}
                                lightColor={Colors.dark.text}
                                darkColor={Colors.light.text}
                            >
                                No comments.
                            </ThemedText>
                        )}
                    </ScrollView>
                </View>

            </Animated.View>
        </>
    );
};


export default CommentsTray;
