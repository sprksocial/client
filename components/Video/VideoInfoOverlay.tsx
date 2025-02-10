// VideoInfoOverlay.tsx
import React, { useState } from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import VideoSide from './VideoSide';
import VideoBottom from './VideoBottom';
import CommentsTray from './CommentsTray';
import { VideoInfoOverlayProps } from '@/types/Interfaces';
import VideoTop from './VideoTop';

const VideoInfoOverlay: React.FC<VideoInfoOverlayProps> = ({ videoData }) => {
  const [isCommentsVisible, setIsCommentsVisible] = useState(false);

  const handleComments = () => {
    setIsCommentsVisible(true);
  };

  const handleCloseComments = () => {
    setIsCommentsVisible(false);
  };

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
      <CommentsTray visible={isCommentsVisible} onClose={handleCloseComments} comments={videoData.comments ?? []} />
    </View>
  );
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
    paddingHorizontal: 20,
    paddingBottom: 60,
    marginBottom: 0,
  },
});

export default VideoInfoOverlay;
