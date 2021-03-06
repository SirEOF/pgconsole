def console_loop
	# This is the main loop that will handle all the commands from the user
	# Like a command shell
	loop do
		print "pgconsole>"
		command = gets.chomp
		# User input is passed to the run_command method which handles launching specific modules
		output = run_command(command)
		break if output == :quit
	end
end

def run_command(command)
	# This is the method that handles user inpot from the main console
	# Whatever command is entered it handled by this case statement and passed
	# To its proper function
	case command
	when 'quit'
		return :quit
	when 'help'
		puts help
	when 'emails'
		launch_enum_emails
	when 'sitemap'
		launch_sitemap_creation
	when 'spider'
		launch_spider_module
	when 'enum'
		enum_webserver
	when 'hosts'
		Host.get_hosts
	when 'clear'
		system("clear")
	else
		puts "[-] Invalid Option, try 'help'"
	end
end

def launch_enum_emails
	print "[.] Target URL: "
	# Take in a URL from the user and spider it
	target = gets.chomp
	if clean_url(target)
		begin
			Anemone.crawl(target) do |anemone|
				anemone.on_every_page do |page|
					# enum email addresses
					emails = http_get("#{page.url}")
					unless emails == nil
						emails.each do |email|
							puts "#{page.url}\t#{email}"
						end
					end
				end
			end
		catch
			puts "An Error has occured while crawling the url"
		end
	else
		puts "[-] Error: must provide an absolute URL 'http://www...'"
		console_loop
	end
end

def launch_sitemap_creation
	print "[.] Target URL: "
	# Take in a URL from the user and spider it
	target = gets.chomp
	if clean_url(target)
		# code to create sitemap
		begin
			Anemone.crawl(target) do |anemone|
				anemone.on_every_page do |page|
					# print urls to stdout
					print "#{page.url}\n"
				end
			end
		catch
			puts "An Error has occured while crawling the url"
		end
	else
		puts "[-] Error: must provide an absolute URL 'http://www...'"
		console_loop
	end
end

def launch_spider_module
	print "[.] Target URL: "
	# Take in a URL from the user and spider it
	target = gets.chomp
	if clean_url(target)
		spider = Spider.new(target)
		spider.crawl!
	else
		puts "[-] Error: must provide an absolute URL 'http://www...'"
		console_loop
	end
	# Once finished build a sitemap
	Host.new(spider.domain, spider.visited) unless Host.host_exists(spider.domain)
end

def clean_url(url)
	# Check if a url is clean and can be processed by the 'Mechanise' gem
	if url.to_s.include?("http:\/\/www.")
		return true
	else
		return false
	end
end

def enum_webserver
	# This method is used to start the enumeration module
	print "[.] Enter URL to enumerate: "
	domain = gets.chomp
	if clean_url(domain)
		# Creates an instance of the Target class and starts enumerating it
		target = Target.new(domain)
		target.enumerate!
	else
		puts "[-] Error: must provide an absolute URL 'http://www...'"
		console_loop
	end  
end

def http_get(url)
	# ignore if https url
	if url =~ /https/
		puts "This tool does not support HTTPS at this time"

		# code to handle https
		return
	end

	uri = URI.parse(url)
	body = Net::HTTP.get(uri)

	emails = []
	if body =~ /\b[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/
		emails << body.match(/\b[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}\b/)
		unless emails == nil
			return emails
		end
	end
end

def help
	# This is the help menu
	help_string = "\n\n  --Commands--"
	help_string += "\n\n"
	help_string += "help\t-\tDisplays this help screen\r\n"
	help_string += "sitemap\t-\tCreates a Sitemap of targets url\r\n"
	help_string += "spider\t-\tSpiders a specified target website\r\n"
	help_string += "emails\t-\tEnumeates email addresses within a url\r\n"
	help_string += "enum\t-\tRuns web enumeration modules against a specified URL\n"
	help_string += "hosts\t-\tDisplay information about scanned hosts\n"
	help_string += "quit\t-\tExits the applicaiton\r\n"
	help_string += "\n"
	return help_string
end