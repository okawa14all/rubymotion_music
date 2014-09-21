class MusicController < UIViewController
  DEFAULT_MUSIC_CELL_ID = "DefaultMusicCell"
  SEARCHED_MUSIC_CELL_ID = "SearchedMusicCell"

  def viewDidLoad
    super

    self.edgesForExtendedLayout = UIRectEdgeNone

    @musics = []
    @user_searched_musics = []

    @country_code = NSLocale.currentLocale.objectForKey(NSLocaleCountryCode)

    rmq.stylesheet = MusicControllerStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    @searchBar = rmq.append(UISearchBar, :music_search_bar).get.tap do |sb|
      sb.placeholder = '今聴いている曲はなんですか？'
      sb.setShowsCancelButton(false, animated:false)
      sb.resignFirstResponder
      sb.delegate = self
    end

    @search_controller = UISearchDisplayController.alloc.initWithSearchBar(@searchBar, contentsController:self).tap do |sc|
      sc.delegate = self
      sc.searchResultsDataSource = self
      sc.searchResultsDelegate = self
    end

    @tableView = rmq.append(UITableView, :music_table).get.tap do |tv|
      tv.delegate = self
      tv.dataSource = self
      tv.setSeparatorInset(UIEdgeInsetsZero)
    end

    # get now playing music
    player = MPMusicPlayerController.iPodMusicPlayer
    currentItem = player.nowPlayingItem

    if currentItem
      puts title = currentItem.valueForProperty(MPMediaItemPropertyTitle)
      puts genre = currentItem.valueForProperty(MPMediaItemPropertyGenre)
      puts album_title = currentItem.valueForProperty(MPMediaItemPropertyAlbumTitle)
      puts artist = currentItem.valueForProperty(MPMediaItemPropertyArtist)

      Music.search_from_itunes(term: title, country: @country_code) do |musics, error|
        if error
          App.alert(error.localizedDescription)
        else
          @musics.concat(musics)
          @tableView.reloadData
        end
      end

      Music.search_from_soundcloud(q: title) do |musics, error|
        if error
          App.alert(error.localizedDescription)
        else
          @musics.concat(musics)
          @tableView.reloadData
        end
      end
    end

  end

  def init_nav
    self.title = '音楽'
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.alloc.initWithTitle(
        'キャンセル',
        style: UIBarButtonItemStylePlain,
        target: self,
        action: :dismissView
      )
    end
  end

  def dismissView
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  # UITableView delegate
  def tableView(table_view, numberOfRowsInSection: section)
    case
    when table_view.instance_of?(UITableView)
      @musics.length
    when table_view.instance_of?(UISearchResultsTableView)
      @user_searched_musics.length
    end
  end

  def tableView(table_view, heightForRowAtIndexPath: index_path)
    rmq.stylesheet.music_cell_height
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    case
    when table_view.instance_of?(UITableView)
      music = @musics[index_path.row]
      identifier = DEFAULT_MUSIC_CELL_ID
    when table_view.instance_of?(UISearchResultsTableView)
      music = @user_searched_musics[index_path.row]
      identifier = SEARCHED_MUSIC_CELL_ID
    end

    cell = table_view.dequeueReusableCellWithIdentifier(identifier) || begin
      rmq.create(
        MusicCell, :music_cell,
        reuse_identifier: identifier,
        cell_style: UITableViewCellStyleSubtitle
      ).get
    end

    cell.update(music)
    cell
  end

  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    case
    when table_view.instance_of?(UITableView)
      music = @musics[index_path.row]
    when table_view.instance_of?(UISearchResultsTableView)
      music = @user_searched_musics[index_path.row]
    end
    open_post_controller(music)
  end

  # UISearchBar delegate
  def searchBarShouldBeginEditing(searchBar)
    searchBar.showsScopeBar = true
    searchBar.sizeToFit
    searchBar.setShowsCancelButton(true, animated:true)
    true
  end

  def searchBarShouldEndEditing(searchBar)
    searchBar.showsScopeBar = false
    searchBar.sizeToFit
    searchBar.setShowsCancelButton(false, animated:true)
    true
  end

  def searchBarCancelButtonClicked(searchBar)
    searchBar.resignFirstResponder
  end

  def searchBarSearchButtonClicked(searchBar)
    searchBar.resignFirstResponder

    if searchBar.text.present?
      Music.search_from_itunes(term: searchBar.text, country: @country_code) do |musics, error|
        if error
          App.alert(error.localizedDescription)
        else
          @user_searched_musics.concat(musics)
          @search_controller.searchResultsTableView.reloadData
        end
      end

      Music.search_from_soundcloud(q: searchBar.text) do |musics, error|
        if error
          App.alert(error.localizedDescription)
        else
          @user_searched_musics.concat(musics)
          @search_controller.searchResultsTableView.reloadData
        end
      end
    end
  end

  # SearchDisplayController delegate
  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    false
  end

  # open next view_controller
  def open_post_controller(music)
    controller = PostController.new
    controller.music = music
    self.navigationController.pushViewController(controller, animated:true)
  end
end
