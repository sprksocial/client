import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  StyleSheet,
  useColorScheme,
  TouchableOpacity,
  Dimensions,
  SafeAreaView,
  ScrollView,
  Animated,
  StyleProp,
  ViewStyle,
} from 'react-native';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';

interface BottomSliderProps {
  visible: boolean;
  onClose?: () => void;
  title?: string;
  renderHeader?: () => React.ReactNode;
  animationDuration?: number;
  containerStyle?: StyleProp<ViewStyle>;
  headerStyle?: StyleProp<ViewStyle>;
  contentStyle?: StyleProp<ViewStyle>;
  children?: React.ReactNode;
}

const BottomSlider: React.FC<BottomSliderProps> = ({
  visible,
  onClose,
  title = 'Content Settings',
  renderHeader,
  animationDuration = 150,
  containerStyle,
  headerStyle,
  contentStyle,
  children,
}) => {
  const screenHeight = Dimensions.get('screen').height;
  const colorScheme: 'light' | 'dark' = useColorScheme() as 'light' | 'dark';
  
  const translateY = useRef(new Animated.Value(screenHeight)).current;


  useEffect(() => {
    if (visible) {
      Animated.timing(translateY, {
        toValue: 0,
        duration: animationDuration,
        useNativeDriver: true,
      }).start();
    } else {
      Animated.timing(translateY, {
        toValue: screenHeight,
        duration: animationDuration,
        useNativeDriver: true,
      }).start(({ finished }) => {
        if (finished && onClose) {
          onClose();
        }
      });
    }
  }, [visible, onClose, translateY, animationDuration, screenHeight]);

  const handleClose = () => {
    if (onClose) {
      onClose();
    }
  };

  const styles = StyleSheet.create({
    wrapper: {
      position: 'absolute',
      width: '100%',
      height: '100%',
      zIndex: 999,
    },
    sliderContainer: {
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      width: '100%',
      height: screenHeight,
      transform: [{ translateY }],
    },
    headerContainer: {
      width: '100%',
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      paddingHorizontal: 10,
      paddingTop: 10,
    },
    closeButton: {
      padding: 5,
      borderRadius: 50,
    },
    sliderContent: {
      width: '100%',
      height: '100%',
      padding: 10,
      marginBottom: 20,
    },
  });

  const defaultHeader = (
    <View style={[styles.headerContainer, headerStyle]}>
      <ThemedText type="title">{title}</ThemedText>
      <TouchableOpacity style={styles.closeButton} onPress={handleClose}>
        <Ionicons
          name="close"
          size={24}
          color={Colors[colorScheme ?? 'light'].text}
        />
      </TouchableOpacity>
    </View>
  );

  const header = renderHeader ? renderHeader() : defaultHeader;

  return (
    <View pointerEvents={visible ? 'auto' : 'none'} style={[styles.wrapper, containerStyle]}>
      <Animated.View style={styles.sliderContainer}>
        <SafeAreaView>
          {header}
          <ScrollView style={[styles.sliderContent, contentStyle]}>
            {children}
          </ScrollView>
        </SafeAreaView>
      </Animated.View>
    </View>
  );
};

export default BottomSlider;