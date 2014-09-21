class MainController < UIViewController

  def viewDidLoad
    super

    # Sets a top of 0 to be below the navigation control, it's best not to do this
    # self.edgesForExtendedLayout = UIRectEdgeNone

    rmq.stylesheet = MainStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    rmq.append(UIButton, :post_button).on(:touch) do |sender|
      open_music_controller
    end
  end

  def open_music_controller
    controller = MusicController.new
    nav_controller = UINavigationController.alloc.initWithRootViewController(controller)
    self.presentViewController(nav_controller, animated:true, completion:nil)
  end

  def init_nav
    self.title = 'post music'
  end

end
