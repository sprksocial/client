// VideoScreen.js
import React, { useState, useEffect, useRef } from 'react';
import {
  StyleSheet,
  View,
  TouchableWithoutFeedback,
  Animated,
  PanResponder,
} from 'react-native';
import { useEvent } from 'expo';
import { useVideoPlayer, VideoView, VideoSource } from 'expo-video';
import ControlsOverlay from './ControlsOverlay';
import VideoInfoOverlay from './VideoInfoOverlay';
import { VideoScreenProps } from '@/types/Interfaces';
import { ThemedText } from '../ThemedText';
import { LinearGradient } from 'expo-linear-gradient';

export default function VideoScreen({
  videoData,
}: VideoScreenProps) {

  const player = useVideoPlayer(videoData.embed?.playlist as VideoSource, (playerInstance) => {
    playerInstance.loop = true;
    playerInstance.timeUpdateEventInterval = 500;
    if (videoData.isActive) {
      playerInstance.play();
    } else {
      playerInstance.pause();
    }
  });

  const { isPlaying } = useEvent(player, 'playingChange', {
    isPlaying: player.playing
  });

  const [videoProgress, setVideoProgress] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      if (player.playing) {
        setVideoProgress(player.currentTime ?? 0);
      }
    }, 500);

    return () => clearInterval(interval);
  }, [player]);

  const videoTime = useEvent(player, 'timeUpdate', {
    currentTime: player.currentTime ?? 0,
    currentLiveTimestamp: null,
    currentOffsetFromLive: null,
    bufferedPosition: 0,
    duration: player.duration ?? 0,
  });


  const [showControls, setShowControls] = useState(false);
  const controlsOpacity = useRef(new Animated.Value(0)).current;
  const hideControlsTimeout = useRef<NodeJS.Timeout | null>(null);

  const showAndHideControls = () => {
    setShowControls(true);
    Animated.timing(controlsOpacity, {
      toValue: 1,
      duration: 200,
      useNativeDriver: true,
    }).start();

    if (hideControlsTimeout.current) {
      clearTimeout(hideControlsTimeout.current);
    }

    hideControlsTimeout.current = setTimeout(() => {
      Animated.timing(controlsOpacity, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }).start(() => {
        setShowControls(false);
      });
    }, 800);
  };

  useEffect(() => {
    if (videoData.isActive) {
      player.currentTime = 0;
      player.play();
    } else {
      player.pause();
    }
  }, [videoData.isActive, player]);

  useEffect(() => {
    return () => {
      if (hideControlsTimeout.current) {
        clearTimeout(hideControlsTimeout.current);
      }
    };
  }, []);

  const handlePlayPause = () => {
    if (isPlaying) {
      player.pause();
    } else {
      player.play();
    }
    showAndHideControls();
  };

  const progressPercentage = player.duration ? (videoProgress / player.duration) * 100 : 0;


  return (
    <TouchableWithoutFeedback onPress={showAndHideControls}>
      <View style={styles.container}>
        <VideoInfoOverlay videoData={videoData} />
        <VideoView
          style={styles.video}
          player={player}
          nativeControls={false}
          allowsVideoFrameAnalysis={false}
        />
             <LinearGradient
        colors={['transparent', 'rgba(0,0,0,0.8)']}
        style={styles.background}
      />
        <View style={styles.progressContainer}>
          <View style={[styles.progressBar, { width: `${progressPercentage}%` }]} />
          <View style={[styles.progressIndicator, { left: `${progressPercentage}%` }]} />
        </View>

        {showControls && (
          <>
            <Animated.View style={[styles.timestampContainer, { opacity: controlsOpacity }]}>
              <ThemedText style={{ color: 'white', position: 'absolute', bottom: 20 }}>
                {`${videoProgress.toFixed(2)}s / ${player.duration.toFixed(2)}s`}
              </ThemedText>
            </Animated.View>
            <ControlsOverlay
              isPlaying={isPlaying}
              onPlayPause={handlePlayPause}
              opacity={controlsOpacity}
            />
          </>
        )}

      </View>
    </TouchableWithoutFeedback>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    height: '100%',
  },
  video: {
    flex: 1,
    width: '100%',
    height: '100%',
    backgroundColor: '#000',
  },
  progressContainer: {
    position: 'absolute',
    bottom: 0,
    width: '100%',
    height: 4,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
  },
  timestampContainer: {
    position: 'absolute',
    bottom: 0,
    width: '100%',
    height: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  progressBar: {
    height: '100%',
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
  },
  background: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    height: 230,
  },
  progressIndicator: {
    position: 'absolute',
    top: 0,
    width: 5,
    height: 5,
    backgroundColor: 'white',
    transform: [{ translateX: -5 }],
  },
});
