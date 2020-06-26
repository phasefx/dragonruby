module Audio

  #############################################################################
  # audio stuff

  def play_bg_music
    @gtk_outputs.sounds << "music/A Long Way.ogg"
  end

  def stop_bg_music
    $gtk.stop_music
  end

end # of Audio
