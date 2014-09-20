require File.expand_path("teststrap", File.dirname(__FILE__))

def setup_with_location(location = "test/test.mp3")
  mock(Open4).popen4("mplayer -slave -quiet \"#{location}\"") { [true,true,true,true] }.any_times
  stub(true).gets { "playback" }
  MPlayer::Slave.new(location)
end

context "MPlayer::Player" do
  setup do
    setup_with_location
  end
  asserts("invalid file") { MPlayer::Slave.new('boooger') }.raises ArgumentError,"Invalid File"
  asserts_topic.assigns(:file)
  asserts_topic.assigns(:pid)
  asserts_topic.assigns(:stdin)
  asserts_topic.assigns(:stdout)
  asserts_topic.assigns(:stderr)
end

context "MPlayer::Player for URL" do
  setup do
    setup_with_location("http://www.example.com/test.mp3")
  end
  denies("url passes") { MPlayer::Slave.new('http://www.example.com/test.mp3') }.raises ArgumentError,"Invalid File"
  asserts_topic.assigns(:file)
  asserts_topic.assigns(:pid)
  asserts_topic.assigns(:stdin)
  asserts_topic.assigns(:stdout)
  asserts_topic.assigns(:stderr)
end

context "MPlayer::Player with screenshots enabled" do
  setup do
    mock(Open4).popen4('mplayer -slave -quiet -vf screenshot "test/test.mp3"') { [true,true,true,true] }
    stub(true).gets { "playback" }
  end
  asserts("new :screenshot") { MPlayer::Slave.new('test/test.mp3', :screenshot => true) }
end

context "MPlayer::Player file with space" do
  setup do
    setup_with_location("test/test space.mp3")
  end
  asserts("invalid file") { MPlayer::Slave.new('boooger') }.raises ArgumentError,"Invalid File"
  asserts_topic.assigns(:file)
  asserts_topic.assigns(:pid)
  asserts_topic.assigns(:stdin)
  asserts_topic.assigns(:stdout)
  asserts_topic.assigns(:stderr)
end
