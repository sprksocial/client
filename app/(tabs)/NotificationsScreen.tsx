import { SafeAreaView, ScrollView, StyleSheet, useColorScheme } from 'react-native';
import { ThemedText } from '@/components/ThemedText';
import { ThemedView } from '@/components/ThemedView';
import ContentWrapper from '@/components/global/ContentWrapper';
import NotificationItem from '@/components/Notifications/NotificationItem';
import { NotificationProps } from '@/types/Interfaces';
import { Colors } from '@/constants/Colors';

const NOTIFICATIONS_DATA: NotificationProps[] = [
  {
    identity: 'like',
    type: { typeName: 'single_user_like' },
    onPress: () => console.log('Alice liked your video'),
    content: {
      title: 'Alice Johnson',
      description: 'liked your video',
      timestamp: new Date(Date.now() - 1 * 3600 * 1000).toISOString(), // 1 hour ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=12',
          displayName: 'Alice Johnson',
          did: 'did:plc:alice001',
          handle: 'alice.j',
        },
      ],
    },
  },
  {
    identity: 'comment',
    type: { typeName: 'single_user_comment' },
    onPress: () => console.log('Bob commented on your video'),
    content: {
      title: 'Bob Smith',
      description: 'commented on your video',
      timestamp: new Date(Date.now() - 2 * 3600 * 1000).toISOString(), // 2 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=13',
          displayName: 'Bob Smith',
          did: 'did:plc:bob002',
          handle: 'bob.s',
        },
      ],
    },
  },
  {
    identity: 'follow',
    type: { typeName: 'single_user_follow' },
    onPress: () => console.log('Charlie followed you'),
    content: {
      title: 'Charlie Davis',
      description: 'followed you',
      timestamp: new Date(Date.now() - 3 * 3600 * 1000).toISOString(), // 3 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=14',
          displayName: 'Charlie Davis',
          did: 'did:plc:charlie003',
          handle: 'charlie.d',
        },
      ],
    },
  },
  {
    identity: 'like',
    type: { typeName: 'multiple_user_like' },
    onPress: () => console.log('Multiple users liked your video'),
    content: {
      title: 'Diana Prince and 3 others',
      description: 'liked your video',
      timestamp: new Date(Date.now() - 4 * 3600 * 1000).toISOString(), // 4 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=15',
          displayName: 'Diana Prince',
          did: 'did:plc:diana004',
          handle: 'diana.p',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=16',
          displayName: 'Edward Norton',
          did: 'did:plc:edward005',
          handle: 'edward.n',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=17',
          displayName: 'Fiona Gallagher',
          did: 'did:plc:fiona006',
          handle: 'fiona.g',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=18',
          displayName: 'George Michael',
          did: 'did:plc:george007',
          handle: 'george.m',
        },
      ],
    },
  },
  {
    identity: 'comment',
    type: { typeName: 'multiple_user_reply' },
    onPress: () => console.log('Multiple users replied to your comment'),
    content: {
      title: 'Hannah, Ian and Jackie',
      description: 'replied to your comment',
      timestamp: new Date(Date.now() - 5 * 3600 * 1000).toISOString(), // 5 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=19',
          displayName: 'Hannah Lee',
          did: 'did:plc:hannah008',
          handle: 'hannah.l',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=20',
          displayName: 'Ian Somerhalder',
          did: 'did:plc:ian009',
          handle: 'ian.s',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=21',
          displayName: 'Jackie Chan',
          did: 'did:plc:jackie010',
          handle: 'jackie.c',
        },
      ],
    },
  },
  {
    identity: 'follow',
    type: { typeName: 'single_user_follow' },
    onPress: () => console.log('Karen followed You'),
    content: {
      title: 'Karen Williams',
      description: 'shared your video',
      timestamp: new Date(Date.now() - 6 * 3600 * 1000).toISOString(), // 6 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=22',
          displayName: 'Karen Williams',
          did: 'did:plc:karen011',
          handle: 'karen.w',
        },
      ],
    },
  },
  {
    identity: 'comment',
    type: { typeName: 'single_user_comment' },
    onPress: () => console.log('Multiple users mentioned you'),
    content: {
      title: 'Leo, Mia and Nina',
      description: 'mentioned you in a comment',
      timestamp: new Date(Date.now() - 7 * 3600 * 1000).toISOString(), // 7 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=23',
          displayName: 'Leo Messi',
          did: 'did:plc:leo012',
          handle: 'leo.m',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=24',
          displayName: 'Mia Khalifa',
          did: 'did:plc:mia013',
          handle: 'mia.k',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=25',
          displayName: 'Nina Dobrev',
          did: 'did:plc:nina014',
          handle: 'nina.d',
        },
      ],
    },
  },
  {
    identity: 'comment',
    type: { typeName: 'single_user_comment' },
    onPress: () => console.log('Olivia commented on your video'),
    content: {
      title: 'Olivia Brown',
      description: 'commented on your video',
      timestamp: new Date(Date.now() - 8 * 3600 * 1000).toISOString(), // 8 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=26',
          displayName: 'Olivia Brown',
          did: 'did:plc:olivia015',
          handle: 'olivia.b',
        },
      ],
    },
  },
  {
    identity: 'follow',
    type: { typeName: 'single_user_follow' },
    onPress: () => console.log('Peter followed you'),
    content: {
      title: 'Peter Parker',
      description: 'followed you',
      timestamp: new Date(Date.now() - 9 * 3600 * 1000).toISOString(), // 9 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=27',
          displayName: 'Peter Parker',
          did: 'did:plc:peter016',
          handle: 'peter.p',
        },
      ],
    },
  },
  {
    identity: 'like',
    type: { typeName: 'multiple_user_like' },
    onPress: () => console.log('Multiple users liked your video'),
    content: {
      title: 'Quincy and 4 others',
      description: 'liked your video',
      timestamp: new Date(Date.now() - 10 * 3600 * 1000).toISOString(), // 10 hours ago
      users: [
        {
          avatar: 'https://picsum.photos/200/300?random=28',
          displayName: 'Quincy Adams',
          did: 'did:plc:quincy017',
          handle: 'quincy.a',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=29',
          displayName: 'Rachel Green',
          did: 'did:plc:rachel018',
          handle: 'rachel.g',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=30',
          displayName: 'Steve Rogers',
          did: 'did:plc:steve019',
          handle: 'steve.r',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=31',
          displayName: 'Tony Stark',
          did: 'did:plc:tony020',
          handle: 'tony.s',
        },
        {
          avatar: 'https://picsum.photos/200/300?random=32',
          displayName: 'Ursula K. Le Guin',
          did: 'did:plc:ursula021',
          handle: 'ursula.k',
        },
      ],
    },
  },
];


export default function NotificationsScreen() {
  const colorScheme = useColorScheme();
  
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
});

  return (
    <SafeAreaView style={styles.container}>
      <ContentWrapper>
        <ScrollView contentContainerStyle={styles.scrollViewContent} showsVerticalScrollIndicator={false}>
        {NOTIFICATIONS_DATA.map((notification, index) => (
          <NotificationItem key={index} notification={notification} />
        ))}
        </ScrollView>
        </ContentWrapper>
    </SafeAreaView>
  );
}
