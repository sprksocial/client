import React, { useState } from 'react';
import { View, StyleSheet, Image, ScrollView, Dimensions, NativeScrollEvent, NativeSyntheticEvent } from 'react-native';
import { BlurView } from 'expo-blur';
import { ThemedText } from '@/components/ThemedText';
import { ImageScreenProps } from '@/types/Interfaces';
import ImageIndex from './ImageIndex';
import VideoInfoOverlay from '../Video/VideoInfoOverlay';
import { LinearGradient } from 'expo-linear-gradient';

export default function ImageScreen({ imageData }: ImageScreenProps) {
  const images = imageData?.embed?.images || [];
  const { width: screenWidth, height: screenHeight } = Dimensions.get('window');
  const TAB_BAR_HEIGHT = screenHeight * 0.1;
  const availableHeight = screenHeight - TAB_BAR_HEIGHT;

  const [currentIndex, setCurrentIndex] = useState(0);

  if (!images || images.length === 0) {
    return (
      <View style={styles.noImageContainer}>
        <ThemedText>No image available</ThemedText>
      </View>
    );
  }

  const handleScroll = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const newIndex = Math.round(event.nativeEvent.contentOffset.x / screenWidth);
    setCurrentIndex(newIndex);
  };

  return (
    <View style={{ ...styles.root, height: screenHeight - TAB_BAR_HEIGHT }}>

      <VideoInfoOverlay videoData={imageData} />
      {images.length > 1 && (

        <View style={styles.pageIndexContainer}>
          {images.map((_, index) => (
            <ImageIndex key={index} index={index} currentIndex={currentIndex} />
          ))}

        </View>

      )}

      <ScrollView
        horizontal
        pagingEnabled
        decelerationRate="fast"
        snapToInterval={screenWidth}
        snapToAlignment="center"
        showsHorizontalScrollIndicator={false}
        onScroll={handleScroll}
        scrollEventThrottle={16}
      >
        {images.map((img, index) => (
          <View key={index} style={[styles.pageContainer, { width: screenWidth }]}>
            <Image source={{ uri: img.fullsize || '' }} style={styles.imageBg} resizeMode="cover" />
            <BlurView intensity={50} style={styles.blurOverlay} tint="dark" />
            <Image source={{ uri: img.fullsize || '' }} style={styles.image} resizeMode="contain" />
          </View>
        ))}

        <LinearGradient
          colors={['transparent', 'rgba(0,0,0,0.8)']}
          style={styles.background}
        />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    backgroundColor: '#000',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    flex: 1,
  },
  noImageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000',
  },
  pageContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    flex: 1,
    width: '100%',
    height: '100%',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  imageBg: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  blurOverlay: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  pageIndexContainer: {
    position: 'absolute',
    bottom: 10,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    zIndex: 1,
  },
  background: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    height: 230,
  },
});