import { PostProps, UserProps } from "@/types/Interfaces";

export const getProfile = async (actor: string): Promise<UserProps | null> => {
  try {
    const res = await fetch(
      `https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=${actor}`
    );

    if (!res.ok) {
      console.error(`Error fetching profile: ${res.status}`);
      return null;
    }

    const profile: UserProps = await res.json();
    return profile;
  } catch (error) {
    console.error("Error fetching profile from Bluesky:", error);
    return null;
  }
};

export const getProfileMedia = async (
  actor: string,
  mediaType: "video" | "image"
): Promise<PostProps[]> => {
  const res = await fetch(
    `https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=${actor}&filter=posts_with_media`
  );

  if (!res.ok) {
    throw new Error(`Failed to fetch media for actor: ${actor}`);
  }

  const data = await res.json();

  if (!data.feed) {
    return [];
  }

  const filteredPosts: PostProps[] = data.feed.filter((item: any) => {
    const embed = item.post.record.embed;
    if (!embed) return false;
    if (mediaType === "video") {
      return embed.$type === "app.bsky.embed.video";
    } else if (mediaType === "image") {
      return embed.$type === "app.bsky.embed.images";
    }
    return false;
  });

  return filteredPosts;
};
