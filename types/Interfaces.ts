export interface UserProps {
    id?: string;
    did: string;
    displayName: string;
    handle: string;
    description?: string;
    avatar: string;
    banner?: string;
    followersCount?: number;
    followsCount?: number;
    videos?: VideoProps[];
    likes?: number;
    views?: number;
    postsCount?: number;
    associated?: object;
    joinedViaStarterPack?: object;
    indexedAt?: string;
    createdAt?: string;
    viewer?: object;
    labels?: object[];
    pinnedPost?: object;
  }

export interface VideoCommentProps {
    id: number;
    author: UserProps;
    content: string;
    likes: number;
    commentReplies?: VideoCommentProps[];
    onLike?: () => void;
    onReply?: () => void;
}

export interface VideoLikeProps {
    amount: number;
    onLike?: () => void;
}

export interface VideoProps {
    id: string;
    videoSource?: string;
    thumbnail?: string;
    creator?: UserProps;
    likes?: VideoLikeProps;
    views?: number;
    isActive?: boolean;
    comments?: VideoCommentProps[];
    shares?: number;
    description?: VideoDescriptionProps;
}

export interface PostProps {
    uri: string;
    cid: string;
    author: UserProps;
    record: PostRecordProps;
    embed?: PostEmbedProps;
    replyCount: number;
    repostCount: number;
    likeCount: number;
    quoteCount: number;
    indexedAt: string;
    labels: any[];
  }
  
  export interface PostRecordProps {
    $type: string;
    createdAt: string;
    embed?: VideoEmbedProps | ImagesEmbedProps;
    langs: string[];
    text: string;
  }
  
  export interface VideoEmbedProps {
    $type: 'app.bsky.embed.video';
    aspectRatio: {
      height: number;
      width: number;
    };
    video: {
      $type: string;
      ref: {
        $link: string;
      };
      mimeType: string;
      size: number;
    };
  }
  
  export interface ImagesEmbedProps {
    $type: 'app.bsky.embed.images';
    images: {
      alt: string;
      aspectRatio: {
        height: number;
        width: number;
      };
      image: {
        $type: string;
        ref: {
          $link: string;
        };
        mimeType: string;
        size: number;
      };
    }[];
  }
  
  export interface PostEmbedProps {
    $type: string;
    cid: string;
    playlist?: string;
    thumbnail?: string;
    aspectRatio?: {
      height: number;
      width: number;
    };
    images?: {
      thumb: string;
      fullsize: string;
      alt: string;
      aspectRatio: {
        height: number;
        width: number;
      };
    }[];
  }


export interface SharesProps {
    amount: number;
}

export interface VideoDescriptionProps {
    content: string;
    hashtags: HashtagsProps;
}

export interface HashtagsProps {
    content: string[];
}

export interface VideoScreenProps {
    videoData: VideoProps;
}

export interface VideoSideProps {
    videoData: VideoProps;
    onComments?: () => void;
}

export interface CommentsTrayProps {
    visible: boolean;
    comments: VideoCommentProps[];
    onClose: () => void;
}

export interface VideoInfoOverlayProps {
    videoData: VideoProps;
}

export interface VideoBottomProps {
    videoData: VideoProps;
}

export interface PlayPauseButtonProps {
    isPlaying: boolean;
    onPress: () => void;
    size?: number;
    color?: string;
  }

export interface NotificationProps {
    identity?: 'like' | 'follow' | 'comment' | 'default';
    type?: NotificationType;
    onPress?: () => void;
    content?: NotificationContentProps;
}

export interface NotificationType {
    typeName: 'single_user_comment' | 'single_user_reply' | 'single_user_like' | 'single_user_follow' | 'multiple_user_reply' | 'multiple_user_like' | 'multiple_user_follow' | 'default',
}

export interface NotificationContentProps {
    title: string;
    description: string;
    timestamp: string;
    users: UserProps[];
    video?: VideoProps;
}

export interface FeaturedProfileProps {
user: UserProps;
  onFollow: () => void;
  isFollowing: boolean;
}