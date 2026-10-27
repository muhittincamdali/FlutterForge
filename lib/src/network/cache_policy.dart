/// How a `CacheInterceptor` may answer a request.
///
/// Only `GET` requests are cached; the policy of any other request is
/// ignored.
enum CachePolicy {
  /// Always ask the network and never store the response.
  noCache,

  /// Ask the network and store a successful response. When the network
  /// cannot be reached, answer from the cache if there is a stored response,
  /// however old it is.
  networkFirst,

  /// Answer from the cache while the stored response is fresh. Once it is
  /// stale, revalidate it with `If-None-Match` or `If-Modified-Since` when the
  /// server sent a validator, or fetch it again.
  cacheFirst,
}
