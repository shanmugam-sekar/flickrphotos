
lets search photos using flickr api.

This app used Swift 5 and XCode 10.2.1.
  
### `Controller`
  ##### FlickrPhotosViewController
    - responsible for the UI representation. UICollectionView is used to display photos list.

### `ViewModel`
  ##### FlickrPhotosViewModel
    - viewmodel delegates the viewstate changes to controller and controller reacts to it.
    - view communicates with service layer through viewmodel.

### `Service`
  ##### FlickrPhotoSearchService
    - responsible for providing data. data can either come from api layer or from persistance storage layer.  
    - currently service fetching data from api layer.

### `API`
  ##### FlickrPhotosSearchAPI 
    - communicates with network layer and parsing the response data.
  ##### FlickrPhotosSearchAPIInfo
    - provides flickr api paramters.
    
### `Parser`
  ##### Parser
    - generic parser implementation with Decodable protocol conformance.

### `Network`
  ##### FlickrPhotosNetworkManager
    - network calls goes here. urlsession api is used.
    
### `Error`
  ##### Error
    - error handling goes here like http error(status code), url loading error, flickr api error, etc.
    
### `Downloader`
  ##### ImageDownloader 
    - handles image downloading and caching.
  ##### Cache
    - used NSCache.
    - Default cache size set to 50MB but it is configurable.
    - Contents of Cache will be automatically cleared on low memory sitations.
    - UIImage is stored as Data in NSCache.
  
  
  
  
