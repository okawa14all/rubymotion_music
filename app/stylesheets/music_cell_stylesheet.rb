module MusicCellStylesheet

  def music_cell_height
    70
  end

  def music_cell(st)
    st.background_color = color.clear
    st.view.selectionStyle = UITableViewCellSelectionStyleNone
  end

  def cell_label(st)
    # st.color = color.white
  end

  def cell_detail_label(st)
    st.color = color.gray
  end

  def image_view(st)
    st.background_color = color.gray
  end
end
