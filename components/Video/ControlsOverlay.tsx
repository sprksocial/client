//ControlsOverlay.tsx
import React from 'react';
import { StyleSheet, Animated, View } from 'react-native';
import PlayPauseButton from './PlayPauseButton';

interface ControlsOverlayProps {
  isPlaying: boolean;
  onPlayPause: () => void;
  opacity: Animated.Value;
}

const ControlsOverlay: React.FC<ControlsOverlayProps> = ({
  isPlaying,
  onPlayPause,
  opacity,
}) => {
  return (
    <Animated.View style={[styles.overlay, { opacity }]}>
      <PlayPauseButton isPlaying={isPlaying} onPress={onPlayPause} />
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,

    justifyContent: 'center',
    alignItems: 'center',

    backgroundColor: 'rgba(0,0,0,0.3)',
  },
});

export default ControlsOverlay;
