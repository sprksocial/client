import { UserProps, VideoCommentProps, VideoProps } from "@/types/Interfaces";


export const USER_DATA: UserProps[] = [
    {
        did: 'did:plc:ypynu36vspziz6xdrta3b42c',
        avatar: 'https://cdn.bsky.app/img/avatar/plain/did:plc:bhexdu6auzdyyn7o7lx3gxjf/bafkreih2zj5re3ik5h37ufhtst3aoapp6pmyxmhoa45gjcjalxk6ncl6hy@jpeg',
        displayName: 'João Davi',
        handle: 'joaodavisn.com',
        description: 'CTO at @reelo.app\nBuilding the future of social networks on ATmosphere, one network at a time.',
        followersCount: 792,
        followsCount: 119,
        likes: 5000,
        views: 1500,
    },
];

export const COMMENT_DATA: VideoCommentProps[] = [];

COMMENT_DATA.push(
    {
        id: 1,
        author: USER_DATA[0],
        content:
          'Que legal! Gostei muito do seu vídeo! Continue assim! 😍',
        likes: 123,
        commentReplies: [],
    },
    {
        id: 2,
        author: USER_DATA[0],
        content: 'Hey! I really liked your video! What do you think of mine? Keep it up! I hope we can collaborate soon! 😊',
        likes: 12,
        commentReplies: [],
      },
      {
        id: 3,
        author: USER_DATA[0],
        content: 'This is a comment!',
        likes: 5,
        commentReplies: [
          COMMENT_DATA[0],
        ],
      },
);

export const VIDEO_DATA: VideoProps[] = [
  {
    id: 'dkOm2iroj3mt747sd4qqnr1',
    videoSource: 'https://video.reelo.app/sample.mp4',
    thumbnail: 'https://f.feridinha.com/rTd4R.png',
    views: 1000,
    likes: { amount: 18, onLike: () => console.log('Liked video') },
    creator: USER_DATA[0],
    shares: 8,
    description: {
      content:
        'Our very first video here! What do you think? Use #sparks so we can see your videos! 💙',
      hashtags: {
        content: ['sparksapp', 'firstvideo', 'newapp', 'sparks'],
      },
    },
    comments: [
        COMMENT_DATA[0],
        COMMENT_DATA[1],
        COMMENT_DATA[2],
    ],
    isActive: false,
  },
  
];

export const did = 'did:plc:cveom2iroj3mt747sd4qqnr2';

const getUserData = (id: string) => {
  return new Promise<UserProps>((resolve) => {
    setTimeout(() => {
      resolve(USER_DATA[0]);
    }, 1000);
  });
}

const getVideoData = (id: string) => {
  return new Promise<VideoProps>((resolve) => {
    setTimeout(() => {
      resolve(VIDEO_DATA[0]);
    }, 1000);
  });
}

export const MOCK_DATA = {
  getUserData,
  getVideoData,
};
