import { SafeAreaView, ScrollView, StyleSheet, useColorScheme, View } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import ContentWrapper from '@/components/global/ContentWrapper';
import { Colors } from '@/constants/Colors';
import SearchBar from '@/components/Search/SearchBar';
import { UserProps, VideoProps } from '@/types/Interfaces';
import VideoDisplay from '@/components/Profile/VideoDisplay';
import FeaturedProfile from '@/components/Search/FeaturedProfile';

export default function SearchScreen() {
  
    const colorScheme = useColorScheme();
const VIDEO_DATA: VideoProps[] = Array.from({ length: 10 }, (_, index) => ({
  id: `video-${index}`,
  thumbnail: `https://picsum.photos/200/300?random=${index + 2}`,
  likes: { amount: Math.floor(Math.random() * 1000) },
  views: Math.floor(Math.random() * 5000),
}));

const USER_DATA: UserProps = {
  image: 'https://f.feridinha.com/rTd4R.png',
  name: 'Sparks',
  handler: 'sprks.app',
  did: 'did:plc:abc123',
  followers: 2500,
  following: 300,
  likes: 5000,
  views: 1500,
};

    const styles = StyleSheet.create({
      container: {
        backgroundColor: Colors[colorScheme ?? 'light'].background,
        height: '100%',
        alignContent: 'center',
        justifyContent: 'center',
      },
      scrollViewContent: {
        flexGrow: 1,
        paddingBottom: 20,
      },
      videoGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
      },
    });
  
  return (
    <SafeAreaView style={styles.container}>
      <ContentWrapper>
        <ScrollView contentContainerStyle={styles.scrollViewContent} showsVerticalScrollIndicator={false}>
        <SearchBar onSearch={()=>{}}/>
        <FeaturedProfile user={USER_DATA} isFollowing={false} onFollow={()=>{}} />

        <View style={styles.videoGrid}>
              {VIDEO_DATA.map((video) => (
                <VideoDisplay key={video.id} videoSource={video} />
              ))}
            </View>
            </ScrollView>
        </ContentWrapper>
    </SafeAreaView>
  );
}

