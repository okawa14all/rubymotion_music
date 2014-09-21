class MusicControllerStylesheet < ApplicationStylesheet
  # Add your view stylesheets here. You can then override styles if needed, example:
  include MusicCellStylesheet

  def setup
    # Add stylesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    st.background_color = color.white
  end

  def music_search_bar(st)
    st.frame = { l: 0, t: 0, w: app_width, h: 44 }
  end

  def music_table(st)
    st.frame = { l: 0, t: 44, w: app_width, h: app_height - 44 }
  end
end
