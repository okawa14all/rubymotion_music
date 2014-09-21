class MusicCell < UITableViewCell

  def rmq_build
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    q = rmq(self.contentView)
    @name = q.build(self.textLabel, :cell_label).get
    @details = q.build(self.detailTextLabel, :cell_detail_label).get
  end

  def update(music, &callback)
    @name.text = music.track_name
    @details.text = "#{music.artist_name}:#{music.collection_name}"

    self.imageView.setImageWithURLRequest(
      NSURLRequest.requestWithURL(NSURL.URLWithString(music.artwork_url)),
      placeholderImage: nil,
      success: -> (request, response, image) {
        self.setNeedsLayout
        self.imageView.image = image
      },
      failure: -> (request, response, error) {
        puts "failed to load image: #{music.track_id}"
      }
    )
  end

end
