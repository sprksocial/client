// src/api/videoService.ts
import { VideoProps } from '@/types/Interfaces';

const extractHashtags = (text: string): string[] => {
  if (!text) return [];
  const match = text.match(/#[\w]+/g);
  return match ? match.map(tag => tag.replace('#', '')) : [];
};

export const fetchTrendingVideos = async (): Promise<VideoProps[]> => {
  try {
    const res = await fetch(
      'https://public.api.bsky.app/xrpc/app.bsky.feed.getFeed?feed=at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot&limit=100'
    );
    const data = await res.json();
    if (!data || !data.feed) return [];

    const mappedVideos: VideoProps[] = data.feed
      .map((item: any, idx: number) => {
        const post = item?.post;
        const record = post?.record;
        const author = post?.author;
        const embed = post?.embed;

        if (!post || !record || !author) {
          return null;
        }

        if (!embed || embed.$type !== 'app.bsky.embed.video#view') {
          return null;
        }

        const likeCount = post.likeCount || 0;
        const shareCount = post.repostCount || 0;
        const textContent = record.text || '';

        const videoSource = embed.playlist || '';
        const thumbnail   = embed.thumbnail || '';

        const sparkVideo: VideoProps = {
          id: post.cid || `bluesky-video-${idx}`,
          videoSource,
          thumbnail,
          creator: {
            id: author.did,
            name: author.displayName || author.handle,
            image: author.avatar,
            handler: author.handle,
            bio: author.bio,
            did: author.did,
          },
          likes: {
            amount: likeCount,
            onLike: () => console.log(`Liked video ${post.cid}`),
          },
          views: 0,
          shares: shareCount,
          description: {
            content: textContent,
            hashtags: {
              content: extractHashtags(textContent),
            },
          },
          comments: [],
          isActive: false,
        };

        return sparkVideo;
      })
      .filter((v: VideoProps | null): v is VideoProps => v !== null);

    return mappedVideos;
  } catch (error) {
    console.log('Error fetching Bluesky feed:', error);
    return [];
  }
};