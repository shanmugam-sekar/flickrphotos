# flickrphotos
you can search photos from flickr

# Models :-
  Photo, PhotosList, FlickrPhotoSearchResponse - handled success and failure flickr responses.
  
# FlickrPhotosViewController :- 
  responsible for the UI representation.

# FlickrPhotosViewModel :-
  viewcontroller operates on values from this viewmodel class. responsible to communicate with service class.

#  FlickrPhotoSearchService :-
  calls API layer. Service layer will abstract fetching data part . data will come from either api or some persistance storage. 

# FlickrPhotosSearchAPI :-
  calls Network manager layer and responsible for parsing the response.
  
# FlickrPhotosNetworkManager :-
  calls underlying ios network api and prepares requests.

# ImageDownloader :- 
  responsible for image downloading and caching it. 
  

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
  
  
  
  
  
