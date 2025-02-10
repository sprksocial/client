import React from 'react';
import { TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { PlayPauseButtonProps } from '@/types/Interfaces';


const PlayPauseButton: React.FC<PlayPauseButtonProps> = ({
  isPlaying,
  onPress,
  size = 80,
  color = '#ffffffAA',
}) => {
  return (
    <TouchableOpacity onPress={onPress}>
      <Ionicons
        name={isPlaying ? 'pause-circle' : 'play-circle'}
        size={size}
        color={color}
      />
    </TouchableOpacity>
  );
};

export default PlayPauseButton;
