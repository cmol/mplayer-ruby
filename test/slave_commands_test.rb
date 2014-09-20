require File.expand_path("teststrap", File.dirname(__FILE__))

context "MPlayer::SlaveCommands" do
  setup_player

  context "pause" do
    setup { mock_command @player, "pause" }
    asserts("returns true") { @player.pause }
  end

  context "quit" do
    setup do
      mock_command @player, "quit"
      mock(@player.stdin).close { true } ; @player
    end
    asserts("returns true") { @player.quit }
  end

  context "volume" do
    asserts("incorrect action") { @player.volume :boo }.equals false

    context "increases" do
      setup { mock_command @player, "volume 1","Volume: 10 %\n",/Volume/ }
      asserts("returns true") { @player.volume :up }.equals "10"
    end

    context "decreases" do
      setup { mock_command @player, "volume 0","Volume: 10 %\n",/Volume/ }
      asserts("returns true") { @player.volume :down }.equals "10"
    end

    context "sets volume" do
      setup { mock_command @player, "volume 40 1","Volume: 10 %\n",/Volume/ }
      asserts("returns true") { @player.volume :set,40 }.equals "10"
    end
  end

  context "seek" do

    context "by relative" do
      setup { mock_command @player, "seek 5 0","Position: 10 %\n",/Position/ }
      asserts("seek 5") { @player.seek 5 }
    end

    context "explicit relative" do
      setup { mock_command @player, "seek 5 0","Position: 10 %\n",/Position/ }
      asserts("seek 5,:relative") { @player.seek 5,:relative }.equals "10"
    end

    context "by percentage" do
      setup { mock_command @player, "seek 5 1","Position: 10 %\n",/Position/ }
      asserts("seek 5,:percent") { @player.seek 5,:percent }.equals "10"
    end

    context "by absolute" do
      setup { mock_command @player, "seek 5 2","Position: 10 %\n",/Position/ }
      asserts("seek 5,:absolute") { @player.seek 5,:absolute }.equals "10"
    end
  end

  context "edl_mark" do
    setup { mock_command @player, "edl_mark"}
    asserts("returns true") { @player.edl_mark }
  end

  context "speed_incr" do
    setup { mock_command @player, "speed_incr 5","Speed: x   10",/Speed/ }
    asserts("speed_incr 5") { @player.speed_incr 5 }.equals "10"
  end

  context "speed_mult" do
    setup { mock_command @player, "speed_mult 5","Speed: x   10",/Speed/ }
    asserts("speed_mult 5") { @player.speed_mult 5 }.equals "10"
  end

  context "speed_set" do
    setup { mock_command @player, "speed_set 5","Speed: x   10",/Speed/ }
    asserts("speed_set 5") { @player.speed_set 5 }.equals "10"
  end

  context "speed_set speed_mult speed_incr raise error" do
    asserts("speed_incr 6") {  @player.speed_incr 6 }.raises ArgumentError,"Value must be less than 6"
    asserts("speed_mult 6") {  @player.speed_mult 6 }.raises ArgumentError,"Value must be less than 6"
    asserts("speed_set 6") {  @player.speed_set 6 }.raises ArgumentError,"Value must be less than 6"
  end

  context "speed" do

    context "increment" do
      setup { mock(@player).speed_incr(5) { true } }
      asserts("speed 5,:increment") { @player.speed 5,:increment }
    end

    context "multiply" do
      setup { mock(@player).speed_mult(5) { true } }
      asserts("speed 5,:multiply") { @player.speed 5,:multiply }
    end

    context "set" do
      setup { mock(@player).speed_set(5) { true } }
      asserts("speed 5") {  @player.speed 5 }
    end

    context "explicit set" do
      setup { mock(@player).speed_set(5) { true } }
      asserts("speed 5, :set") {  @player.speed 5,:set }
    end
  end

  context "frame_step" do
    setup { mock_command @player, "frame_step" }
    asserts("returns true") { @player.frame_step }
  end

  context "pt_step" do

    context "forced" do
      setup { mock_command @player, "pt_step 5 1" }
      asserts("pt_step 5, :force") { @player.pt_step 5, :force }
    end

    context "not forced" do
      setup { mock_command @player, "pt_step 5 0"  }
      asserts("pt_step 5") {  @player.pt_step 5 }
    end

    context "explicit not forced" do
      setup { mock_command @player, "pt_step 5 0"  }
      asserts("pt_step 5, :no_force") { @player.pt_step 5, :no_force }
    end
  end

  context "pt_up_step" do

    context "forced" do
      setup { mock_command @player, "pt_up_step 5 1"}
      asserts("pt_up_step 5, :force") { @player.pt_up_step 5, :force }
    end

    context "not forced" do
      setup { mock_command @player, "pt_up_step 5 0" }
      asserts("pt_up_step 5") { @player.pt_up_step 5 }
    end

    context "explicit not forced" do
      setup { mock_command @player, "pt_up_step 5 0" }
      asserts("pt_up_step 5, :no_force") { @player.pt_up_step 5, :no_force }
    end
  end

  context "alt_src_step" do
    setup { mock_command @player, "alt_src_step 5" }
    asserts("returns true") { @player.alt_src_step 5 }
  end

  context "loop" do

    context "none" do
      setup { mock_command @player,"loop -1" }
      asserts("loop :none") { @player.loop :none }
    end

    context "forever" do
      setup { mock_command @player, "loop 0" }
      asserts("loop") { @player.loop }
    end

    context "explicit forever" do
      setup { mock_command @player, "loop 0" }
      asserts("loop :forever") { @player.loop :forever }
    end

    context "set value" do
      setup { mock_command @player,"loop 5" }
      asserts("loop :set, 5") { @player.loop :set, 5 }
    end
  end

  context "use_master" do
    setup { mock_command @player, "use_master" }
    asserts("returns true") { @player.use_master }
  end

  context "mute" do

    context "toggle" do
      setup { mock_command @player, "mute", "Mute: enabled",/Mute/}
      asserts("returns true") { @player.mute }.equals "enabled"
    end

    context "set on" do
      setup { mock_command @player, "mute 1","Mute: enabled",/Mute/}
      asserts("mute :on") { @player.mute :on }.equals "enabled"
    end

    context "set off" do
      setup { mock_command @player, "mute 0","Mute: enabled",/Mute/}
      asserts("mute :off") { @player.mute :off }.equals "enabled"
    end
  end

  context "get" do

    %w[time_pos time_length file_name video_codec video_bitrate video_resolution
      audio_codec audio_bitrate audio_samples meta_title meta_artist meta_album
    meta_year meta_comment meta_track meta_genre].each do |info|
      context info do
        resp = case info
        when "time_pos" then "ANS_TIME_POSITION"
        when "time_length" then "ANS_LENGTH"
        when "file_name" then "ANS_FILENAME"
        else "ANS_#{info.upcase}"
        end
        setup { mock_command @player, "get_#{info}","#{resp}='100'",/#{resp}/ }
        asserts("get :#{info}") { @player.get info.to_sym }
      end
    end
  end

  context "load_file" do

    asserts("invalid file") { @player.load_file 'booger' }.raises ArgumentError,"Invalid File"
    [
      ["url", "http://www.example.com/test.mp3"],
      ["file", "test/test.mp3"]
    ].each do |kind, location|
      context kind do
        context "append" do
          setup { mock_command @player, "loadfile \"#{location}\" 1" }
          asserts("load_file #{location}, :append") { @player.load_file location, :append }
        end

        context "no append" do
          setup { mock_command @player, "loadfile \"#{location}\" 0" }
          asserts("load_file #{location}") { @player.load_file location }
        end

        context "explicit no append" do
          setup { mock_command @player, "loadfile \"#{location}\" 0" }
          asserts("load_file #{location}, :no_append") { @player.load_file location, :no_append }
        end
      end
    end
  end

  context "load_list" do

    asserts("invalid playlist") { @player.load_list 'booger' }.raises ArgumentError,"Invalid File"
    [
      ["url", "http://www.example.com/test.mp3"],
      ["file", "test/test.mp3"]
    ].each do |kind, location|
      context kind do
        context "append" do
          setup { mock_command @player, "loadlist \"#{location}\" 1" }
          asserts("load_list #{location}, :append") { @player.load_list location, :append }
        end

        context "no append" do
          setup { mock_command @player, "loadlist \"#{location}\" 0" }
          asserts("load_list #{location}") { @player.load_list location }
          #asserts("load_list #{location}, :no_append") { @player.load_list location, :no_append }
        end

        context "explicit no append" do
          setup { mock_command @player, "loadlist \"#{location}\" 0" }
          asserts("load_list #{location}, :no_append") { @player.load_list location, :no_append }
        end
      end
    end
  end

  context "balance" do
    setup { mock_command @player, "balance 2.1" }
    asserts("blance 2.1") { @player.balance 2.1 }
  end

end
