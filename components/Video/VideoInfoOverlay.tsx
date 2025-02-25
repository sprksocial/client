// VideoInfoOverlay.tsx
import React, { useState } from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import VideoSide from './VideoSide';
import VideoBottom from './VideoBottom';
import CommentsTray from './CommentsTray';
import { VideoInfoOverlayProps } from '@/types/Interfaces';
import { fetchPostThread } from '@/api/videoServices';

const VideoInfoOverlay: React.FC<VideoInfoOverlayProps> = ({ videoData }) => {
  const [isCommentsVisible, setIsCommentsVisible] = useState(false);

  const getVideoPostId = (uri: string) => {
    // "uri": "at://did:plc:rje4snbb7obj6twr4gji7ssm/app.bsky.feed.post/3li53nf2y7k2i",
    const parts = uri.split('/');
    return parts[parts.length - 1];
  };

  const handleComments = () => {
    const postId = getVideoPostId(videoData.uri);
    fetchPostThread(videoData.author.did, postId);
    setIsCommentsVisible(true);
  };


  const comments = fetchPostThread(videoData.author.did, getVideoPostId(videoData.uri));

  const handleCloseComments = () => {
    setIsCommentsVisible(false);
  };

const screenHeight = Dimensions.get('window').height;
  
const styles = StyleSheet.create({
  container: {
    display: 'flex',
    flexDirection: 'row',
    zIndex: 1,
    width: '100%',
    height: screenHeight,
    position: 'absolute',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    paddingHorizontal: 15,
    paddingBottom: 55,
  },
});

  return (
    <View style={styles.container} pointerEvents="box-none">
      <VideoBottom videoData={videoData} />
      <VideoSide
        videoData={videoData}
        onComments={handleComments}
        // Pass other handlers if needed
        // onLike={...}
        // onShare={...}
        // onUserClick={...}
        // onHashTagClick={...}
      />
      {/* <CommentsTray visible={isCommentsVisible} onClose={handleCloseComments} comments={ comments?? []} /> */}
    </View>
  );
};



export default VideoInfoOverlay;
