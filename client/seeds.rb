RailsPerf.storage.builds.drop
RailsPerf.storage.reports.drop

build = RailsPerf::Build.new
build.title = 'Commit abc'
build.global = false
build.target = [['activerecord', { ref: 'bd13ff68ef46ae4389c7afd7a9450e7422813948' }]]
RailsPerf.storage.insert_build(build)

puts "build inserted: #{build.id}"

RailsPerf.storage.reports.insert({build_id: build.id, "component"=>:activerecord, "version"=>"5.0.0beta", "entries"=>[{"label"=>"Model#id", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}, {"label"=>"Model#last", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}, {"label"=>"Model#first", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}]})
RailsPerf.storage.reports.insert({build_id: build.id, "component"=>:router, "version"=>"5.0.0beta", "entries"=>[{"label"=>"Router#id", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}, {"label"=>"Router#find_resource", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}, {"label"=>"Router#another_resource", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}]})


['3.2.0', '4.1.0', '4.2.0'].each do |v|
  build = RailsPerf::Build.new
  build.global = true
  build.target = [['activerecord', v]]
  RailsPerf.storage.insert_build(build)

  RailsPerf.storage.reports.insert({build_id: build.id, "component"=>:activerecord, "version"=>v, "entries"=>[{"label"=>"Model#id", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}, {"label"=>"Model#last", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}, {"label"=>"Model#first", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}]})

  RailsPerf.storage.reports.insert({build_id: build.id, "component"=>:router, "version"=>v, "entries"=>[{"label"=>"Router#id", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}, {"label"=>"Router#find_resource", "iterations"=>17977710, "ips"=>1918249.4567441824, "ips_sd"=>181640}, {"label"=>"Router#another_resource", "iterations"=>17977710, "ips"=>2018249.4567441824, "ips_sd"=>181640}]})
end
