import React, { useCallback, useRef, useState } from 'react';
import { View, StyleSheet, useColorScheme, TouchableOpacity, Button, Dimensions, SafeAreaView, ScrollView } from 'react-native';
import { ThemedText } from '../ThemedText';
import { Colors } from '@/constants/Colors';
import { Ionicons } from '@expo/vector-icons';
import Slider from '@react-native-community/slider';

import { Switch } from 'react-native-gesture-handler';
import { useBottomTabBarHeight } from '@react-navigation/bottom-tabs';
import ActionButton from '../global/ActionButton';

const VideoTop: React.FC = () => {
  const height = Dimensions.get('screen').height;

  const colorScheme: 'light' | 'dark' = useColorScheme() as 'light' | 'dark';
  const [optionsHeight, setOptionsHeight] = useState(0);

  const [suggestiveContent, setSuggestiveContent] = useState(false);
  const [nudity, setNudity] = useState(false);
  const [violence, setViolence] = useState(false);

  const handleCloseOptions = () => {
    let startTime: number | undefined;
    const duration = 150;
    const initialHeight = 0;
    const finalHeight = height;

    const animate = (timestamp: number) => {
      if (!startTime) startTime = timestamp;
      const elapsed = timestamp - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const currentHeight = finalHeight - (finalHeight - initialHeight) * progress;

      setOptionsHeight(currentHeight);

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };

    requestAnimationFrame(animate);
  }

  const handleOpenOptions = () => {
    let startTime: number | undefined;
    const duration = 150;
    const initialHeight = 0;
    const finalHeight = height;

    const animate = (timestamp: number) => {
      if (!startTime) startTime = timestamp;
      const elapsed = timestamp - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const currentHeight = initialHeight + (finalHeight - initialHeight) * progress;

      setOptionsHeight(currentHeight);

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };

    requestAnimationFrame(animate);
  };

  const styles = StyleSheet.create({
    container: {
      alignItems: 'center',
      justifyContent: 'center',
      position: 'absolute',
      width: '100%',
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
    optionsContainer: {
      backgroundColor: Colors[colorScheme ?? 'light'].background,
      position: 'absolute',
      top: height - optionsHeight,
      left: 0,
      right: 0,
      bottom: 0,
      width: '100%',
      height: height,
      justifyContent: 'flex-start',
      alignItems: 'center',
      zIndex: 10,
      display: 'flex',
    },
    feedOptions: {
      flexDirection: 'column',
      alignItems: 'flex-start',
      justifyContent: 'center',
      gap: 10,
      width: '100%',
      marginBottom: 20,
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
      gap: 10,
      backgroundColor: Colors[colorScheme ?? 'light'].tint,
      width: '100%',
      padding: 10,
      borderRadius: 10,
    },
    feedWeight: {
      width: '100%',
      paddingHorizontal: 10,
      flexDirection: 'column',
      alignItems: 'center',
    },
    topNav: {
      top: height * 0.09,
      width: '100%',
      flexDirection: 'row',
      justifyContent: 'center',
      alignItems: 'center',
      position: 'absolute',
      zIndex: 1,
      gap: 10,
    },
    optionsContent: {
      width: '100%',
      height: '100%',
      padding: 10,
      marginBottom: useBottomTabBarHeight(),
    },
    contentHeader: {
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
    }
  });


  const handleAddCustomFeed = () => {
    console.log('Add custom feed');
  };


  type FeedWeights = {
    [key: string]: number;
  };
  
  const [customFeeds, setCustomFeeds] = useState<Array<{
    name: string;
    enabled: boolean;
    selected: boolean;
    origin: string;
    weights: FeedWeights;
  }>>([
    {
      name: 'For You',
      enabled: true,
      selected: true,
      origin: 'spark',
      weights: {
        comedy: 50,
        news: 50,
        trending: 50,
        following: 50,
      }
    },
    {
      name: 'Sports',
      enabled: false,
      selected: false,
      origin: 'spark',
      weights: {
        football: 50,
        basketball: 50,
        baseball: 50,
        soccer: 50,
      }
    },
    {
      name: 'Cute Cats',
      enabled: false,
      selected: false,
      origin: 'spark',
      weights: {
        kittens: 50,
        cats: 50,
        cute: 50,
        funny: 50,
      }
    }
  ]);

  const generateSwitch = (
    color: string,
    title: string,
    value: boolean,
    onValueChange: () => void,
    key: string,
  ) => {
    return (
      <View style={styles.feedOption} key={key}>
        <Switch value={value}
          onValueChange={onValueChange}
          trackColor={{ false: Colors[colorScheme ?? 'light'].underlineColor, true: color }}
        />
        <ThemedText>{title}</ThemedText>
      </View>
    );
  };

  const generateSlider = (
    color: string,
    title: string,
    value: number,
    min: number,
    max: number,
    step: number,
    onValueChange: (value: number) => void,
    sliderKey: string
  ) => {
    return (
      <View style={styles.feedWeight} key={sliderKey}>
        <ThemedText>{title}</ThemedText>
        <Slider
          style={{ width: '100%', height: 40 }}
          minimumValue={min}
          maximumValue={max}
          step={step}
          value={value}
          onValueChange={onValueChange}
          minimumTrackTintColor={Colors[colorScheme ?? 'light'].selectedIcon}
          maximumTrackTintColor={Colors[colorScheme ?? 'light'].underlineColor}
        />
      </View>
    );
  };

  const generateFeedTab = (
    title: string,
    selected: boolean,
    key: string,
  ) => {
    return (
      <TouchableOpacity key={key}>
        <ThemedText type='defaultBold' darkColor={Colors.dark.text} lightColor={Colors.dark.text} style={[styles.text, selected ? { color: Colors.light.background } : {}]}>{title}</ThemedText>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <SafeAreaView style={styles.optionsContainer}>
        <View style={styles.contentHeader}>
          <ThemedText type='title'>Content Settings</ThemedText>
          <TouchableOpacity style={styles.closeButton} onPress={handleCloseOptions}>
            <Ionicons name="close" size={24} color={Colors[colorScheme ?? 'light'].text} />
          </TouchableOpacity>
        </View>
        <ScrollView style={styles.optionsContent}>
        <View style={styles.feedOptions}>
            <ThemedText type='subtitle' lightColor={Colors.dark.underlineColor} darkColor={Colors.light.underlineColor}>Content Types</ThemedText>
            {generateSwitch("#0085FF", "Videos", true, () => {}, "videos")}
            {generateSwitch("#0085FF", "Photos", true, () => {}, "photos")}
            </View>
          <View style={styles.feedOptions}>
            <ThemedText type='subtitle' lightColor={Colors.dark.underlineColor} darkColor={Colors.light.underlineColor}>Content Origin</ThemedText>

            <View style={styles.feedOption}>
              <Switch value={true}
                trackColor={{ false: Colors[colorScheme ?? 'light'].underlineColor, true: Colors.light.selectedIcon }}
              />
              <ThemedText>Spark</ThemedText>
            </View>

            <View style={styles.feedOption}>
              <Switch value={true}
                trackColor={{ false: Colors[colorScheme ?? 'light'].underlineColor, true: "#0085FF" }}
              />
              <ThemedText>BlueSky</ThemedText>
            </View>
          </View>

          <View style={styles.feedOptions}>
            <ThemedText type='subtitle' lightColor={Colors.dark.underlineColor} darkColor={Colors.light.underlineColor}>Filters</ThemedText>
            {generateSwitch("#0085FF", "Suggestive Content", suggestiveContent, () => setSuggestiveContent(!suggestiveContent), "suggestiveContent")}
            {generateSwitch("#0085FF", "Nudity", nudity, () => setNudity(!nudity), "nudity")}
            {generateSwitch("#0085FF", "Violence", violence, () => setViolence(!violence), "violence")}
          </View>
          
          <View style={styles.feedOptions}>
            <ThemedText type='subtitle' lightColor={Colors.dark.underlineColor} darkColor={Colors.light.underlineColor}>Custom Feeds</ThemedText>
            {
              customFeeds.map((feed, index) => (
                <React.Fragment key={`customFeed_${index}`}>
                  {generateSwitch("#0085FF", feed.name, feed.enabled, () => {
                    const newFeeds = customFeeds.slice();
                    newFeeds[index].enabled = !newFeeds[index].enabled;
                    setCustomFeeds(newFeeds);
                  }, `customFeedSwitch_${index}`)}
                  {
                    feed.enabled &&
                    Object.keys(feed.weights).map((weightKey, weightIndex) => (
                      generateSlider(
                        "#0085FF",
                        weightKey,
                        feed.weights[weightKey],
                        0,
                        100,
                        1,
                        (value) => {
                          const newFeeds = customFeeds.slice();
                          newFeeds[index].weights[weightKey] = value;
                          setCustomFeeds(newFeeds);
                        },
                        `customFeedSlider_${index}_${weightKey}`
                      )
                    ))
                  }
                </React.Fragment>
              ))
            }

            <ActionButton title='Add Custom Feed' onPress={handleAddCustomFeed} icon='add' width={'100%'}/>
          </View>


        </ScrollView>
      </SafeAreaView>
      <View style={styles.topNav}>
        {
          customFeeds.map((feed, index) => (
            feed.enabled &&
            generateFeedTab(feed.name, feed.selected, `feedTab_${index}`)
          ))
        }
       
        <TouchableOpacity style={styles.filtersButton} onPress={handleOpenOptions}>
          <Ionicons name="filter" size={24} color={Colors.dark.text} lightColor={Colors.dark.text} />
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default VideoTop;
