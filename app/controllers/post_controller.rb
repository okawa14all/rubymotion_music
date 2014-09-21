class PostController < UIViewController
  attr_accessor :music

  def viewDidLoad
    super

    self.edgesForExtendedLayout = UIRectEdgeNone

    rmq.stylesheet = PostControllerStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    rmq.append(UIImageView, :artwork).get.tap do |imageView|
      imageView.url = music.artwork_url
    end
  end

  def init_nav
    self.title = self.music.track_name
    self.navigationItem.tap do |nav|
      nav.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle(
        '投稿',
        style: UIBarButtonItemStylePlain,
        target: self,
        action: :dismissView
      )
    end
  end

  def dismissView
    self.dismissViewControllerAnimated(true, completion:nil)
  end
end
