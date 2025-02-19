import React from 'react';
import { View, StyleSheet } from 'react-native';

interface ImageIndexProps {
  index: number;
  currentIndex: number;
}

const ImageIndex: React.FC<ImageIndexProps> = ({ index, currentIndex }) => {
  return (
    <View
      style={[
        styles.dot,
        { backgroundColor: index === currentIndex ? 'white' : 'rgba(255, 255, 255, 0.5)' },
      ]}
    />
  );
};

const styles = StyleSheet.create({
  dot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginHorizontal: 5,
  },
});

export default ImageIndex;