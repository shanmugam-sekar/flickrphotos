# flickrphotos
you can search photos from flickr

# NSCache :-
  Used to implement image caching. 
  Default cache size set to 50MB but it is configurable.
  Contents of Cache will be automatically cleared on low memory sitations.
  UIImage is stored as Data in NSCache.
  
# Unit Testing :-
  written for parser to test with images data and error data.
  written for simplecache with cache size set to minimal.
  written for viewmodel to test some basic properties.
  still have to check and needs to be extended.
  
  Followed MVVM & POP. Service , API , Network manager will adopt to their respective protocols. So that we can switch the implementation through DI.
  
  Used basic Observable concept to implement communication between view and viewmodel (unidirectional).
  
  Models implements Decodable protocol.
  
  
  
  
  
