import { UserProps, VideoCommentProps, VideoProps } from "@/types/Interfaces";


export const USER_DATA: UserProps[] = [
    {
        did: 'did:plc:ypynu36vspziz6xdrta3b42c',
        image: 'https://cdn.bsky.app/img/avatar/plain/did:plc:ypynu36vspziz6xdrta3b42c/bafkreifjqb5hn7dqk4pv7c5pwpf4pha5j5uyj3vumcbzx3kf7ft44c4ghy@jpeg',
        name: 'C3B',
        handler: 'ctresb.com',
        bio: 'I do some stuffs…\n22y\nCTO at @reelo.app 🟦\n\n🇧🇷 pt-BR | 🇺🇸 en-US',
        followers: 792,
        following: 119,
        likes: 5000,
        views: 1500,
    },

    // bio max 120 characters
]

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
