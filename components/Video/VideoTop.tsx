import React, { useCallback, useRef } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, Button, Dimensions } from 'react-native';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';

import {
  BottomSheetModal,
  BottomSheetView,
  BottomSheetModalProvider,
} from '@gorhom/bottom-sheet';
import { GestureHandlerRootView, Switch } from 'react-native-gesture-handler';

const VideoTop: React.FC = () => {
  const colorScheme = useColorScheme();

  // ref
  const bottomSheetModalRef = useRef<BottomSheetModal>(null);

  const height = Dimensions.get('window').height;
  // callbacks
  const handlePresentModalPress = useCallback(() => {
    bottomSheetModalRef.current?.present();
  }, []);
  const handleSheetChanges = useCallback((index: number) => {
    console.log('handleSheetChanges', index);
  }, []);
  
const styles = StyleSheet.create({
    container: {
      alignItems: 'center',
      justifyContent: 'center',
      position: 'absolute',
      width: '100%',
        top: '9%',
        zIndex: 1,
        flexDirection: 'row',
    },
    text: {
      fontWeight: 'bold',
      fontSize: 20,
      elevation: 1,
      shadowColor: "#000",
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.25,
    },
    filtersButton: {
      position: 'absolute',
      right: 30,
      alignItems: 'center',
      justifyContent: 'center',
      display: 'flex',
      flexDirection: 'row',
      borderWidth: 0,
    },
    contentContainer: {
      flex: 1,
      alignItems: 'center',
    },
    containerb: {
      backgroundColor: 'transparent',
      width: '100%',
      height: height-150,
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      justifyContent: 'center',
      alignItems: 'center',
    },
    feedOptions: {
      flexDirection: 'column',
      alignItems: 'flex-start',
      justifyContent: 'center',
      marginTop: 10,
      gap: 10,
      width: '100%',
      paddingHorizontal: 10,

    },
    feedOption: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      marginHorizontal: 10,
      gap: 10,
    },
    addFeedOption: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      marginHorizontal: 10,
      gap: 10,
    },
  });


  return (
    <View style={styles.container}>
      <View style={styles.containerb}>
        <BottomSheetModalProvider>
          <BottomSheetModal
            ref={bottomSheetModalRef}
            onChange={handleSheetChanges}
          >
            <BottomSheetView style={styles.contentContainer}>
              <View style={styles.feedOptions}>
              <ThemedText>Feed options</ThemedText>

                <View style={styles.feedOption}>
                <Switch />
                <ThemedText>Images</ThemedText>
                </View>
                <View style={styles.feedOption}>
                  <Switch />
                  <ThemedText>Videos</ThemedText>
                </View>
                <View style={styles.feedOption}>
                  <Switch />
                  <ThemedText>Suggestive Content</ThemedText>
                  </View>
              </View>
              <View style={styles.feedOptions}>
              <ThemedText>Custom Feeds</ThemedText>

                <View style={styles.feedOption}>
                  <Switch value={true}/>
                  <ThemedText>For You</ThemedText>
                </View>
                <View style={styles.addFeedOption}>
                  <Ionicons name="add" size={24} color={Colors.dark.text} lightColor={Colors.dark.text} />
                  <ThemedText>Add Custom Feed</ThemedText>
                </View>
                </View>

              <Button title="Close" onPress={() => bottomSheetModalRef.current?.close()} />

            </BottomSheetView>
        </BottomSheetModal>
        </BottomSheetModalProvider>
      </View>
      <TouchableOpacity>
        <ThemedText type='defaultBold' darkColor={Colors.dark.text} lightColor={Colors.dark.text} style={styles.text}>For You</ThemedText>
      </TouchableOpacity>
      <TouchableOpacity style={styles.filtersButton} onPress={handlePresentModalPress}>
        <Ionicons name="filter" size={24} color={Colors.dark.text} lightColor={Colors.dark.text} />
      </TouchableOpacity>
    </View>
  );
};

export default VideoTop;
