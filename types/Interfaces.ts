export interface UserProps {
    image: string;
    name: string;
    handler: string;
    bio?: string;
    did: string;
    videos?: VideoProps[];
    followers?: number;
    following?: number;
    likes?: number;
    views?: number;
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