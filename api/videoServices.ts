// src/api/videoService.ts
import { PostProps, VideoProps } from '@/types/Interfaces';

const extractHashtags = (text: string): string[] => {
  if (!text) return [];
  const match = text.match(/#[\w]+/g);
  return match ? match.map(tag => tag.replace('#', '')) : [];
};

export const fetchTrendingPosts = async (
  mediaType: "video" | "image"
): Promise<PostProps[]> => {
  try {
    const res = await fetch(
      'https://public.api.bsky.app/xrpc/app.bsky.feed.getFeed?feed=at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot&limit=100'
    );
    const data = await res.json();
    if (!data || !data.feed) return [];

    const posts: PostProps[] = data.feed
      .map((item: any) => item?.post)
      .filter((post: PostProps | undefined): post is PostProps => !!post)
      .filter((post: PostProps) => {
        const embed = post.embed;
        if (!embed) return false;
        if (mediaType === "video") {
          return (
            embed.$type === "app.bsky.embed.video#view" ||
            embed.$type === "app.bsky.embed.video"
          );
        } else if (mediaType === "image") {
          return (
            embed.$type === "app.bsky.embed.images#view" ||
            embed.$type === "app.bsky.embed.images"
          );
        }
        return false;
      });

    return posts;
  } catch (error) {
    console.error("Error fetching trending posts:", error);
    return [];
  }
};

export const fetchPostThread = async (
  author: string,
  postId: string
): Promise<PostProps[]> => {
  try {
    const res = await fetch(
      `https://public.api.bsky.app/xrpc/app.bsky.feed.getPostThread?uri=at://did:plc:${author}/app.bsky.feed.post/${postId}&depth=10`
    );
    const data = await res.json();
    if (!data || !data.thread) return [];

    const posts: PostProps[] = data.thread
      .map((item: any) => item?.post)
      .filter((post: PostProps | undefined): post is PostProps => !!post);

    return posts;
  } catch (error) {
    console.error("Error fetching post thread:", error);
    return [];
  }
};