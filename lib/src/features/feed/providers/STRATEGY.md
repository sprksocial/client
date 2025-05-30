```
n is the number of posts to fetch at a time.
m is the number of posts to load from the database at a time.
f is the number of posts to load in the first load.
freshPostCount is the number of posts we are allowed to load from the database.
freshPostCount starts at f.
isEndOfFeed = false
isCaching = false
initialUris is a List<(AtUri)> that contains the uris of the first f posts loaded from the database.
It is used to avoid loading the same post twice, a problem that can happen if a fetch gets a post that was already loaded in the first load.

load() {
  amountToLoad = min(freshPostCount, m)
  if (amountToLoad > 0) {
    The (amountToLoad) most recent uris are loaded from the database and added to the external loadedUris list.
    external freshPostCount -= amountToLoad
  }
}

loadAndUpdateFirstLoad() {
  The f most recent uris are loaded from the database into a List<(AtUri)> uris
  uptadedPostViews = getPosts(uris)
  cachePosts(uptadedPostViews)
  uris are added to the external loadedUris list.
  external freshPostCount = 0
}
 
fetch(List<(AtUri)> initialUris) {
  Repository fetches a skeleton of n fetchedUris
  All fetchedUris that are in initialUris are removed from fetchedUris to avoid duplicates
  return the fetchedUris
}

store(List<(PostView)> posts) {
  isCaching is set to true.
  updatedPostCount = 0
  query the database for the uris from the posts that already exist
  update them
  updatedPostCount = uris.length
  external freshPostCount += updatedPostCount

  start caching the videos and images of the other posts
  Whenever a video or image finishes downloading, the post is added to DB and external freshPostCount is incremented.
  After (posts.length - updatedPostCount)/2 posts finish downloading, isCaching is set to false.
}

endOfFeed() {
  isEndOfFeed is set to true.
  CircularProgressIndicator is shown at the bottom of the feed.
  Watch freshPostCount: The next time it becomes positive, load() is called and external isEndOfFeed is set to false.
}

endOfNetworkFeed() {
  isEndOfFeed is set to true.
  "No more posts" is shown at the bottom of the feed.
}

User opens the feed for the first time.

loadedUris is a List<(AtUri)> that will be used in a PageView.builder() to build either a FeedPostWidget or a SizedBox.

While loadedUris.length = 0 show CircularProgressIndicator.

Call store(fetch()) to start storing new data into the database.
Call loadAndUpdateFirstLoad() to load the first posts into the feed.

When the user scrolls down (index increments):
- If uris.length - index < 10 && !isCaching
  - response = fetch()
  - If response is empty, endOfNetworkFeed() is called
  - Otherwise, store(response) is called
- If uris.length - index < 10, load() is called.
- If uris.length - index <= 1 && isEndOfFeed = false, endOfFeed() is called.
- The post at [oldIndex - 1] becomes a SizedBox
- If the post at [oldIndex] is a Video, stop playing it
- If the post at [newIndex] is a Video, start playing it
- The post at [newIndex + 1] becomes a new post widget

When the user scrolls up (index decrements):
- The post at [newIndex - 1] becomes a new post widget
- If the post at [newIndex] is a Video, start playing it
- If the post at [oldIndex] is a Video, stop playing it
- The post at [oldIndex + 1] becomes a SizedBox

When the user goes to another feed:
- Old feed becomes inactive
- All post widgets become SizedBox

When the user returns to an inactive feed:
- Feed becomes active
- Posts at [index - 1], [index] and [index + 1] become post widgets
- If the post at [index - 1] is a Video, stop playing it
- If the post at [index] is a Video, start playing it
- If the post at [index + 1] is a Video, stop playing it