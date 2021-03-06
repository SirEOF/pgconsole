class Host
  
  attr_accessor :domain, :links, :forms, :server, :id
  @@num_hosts = 0
  
  def initialize(domain=nil, links=nil)
    self.domain = domain unless !domain
    self.links = links unless !links
    @@num_hosts += 1
    self.id = @@num_hosts
  end
  
  def self.get_hosts
    # This methods prints out the enumerated hosts
    puts "[+] Hosts\r\n"
    ObjectSpace.each_object.select{|obj| obj.class == Host}.each do |host|
      puts "\t[Domain:] " + host.domain.to_s + "\t|\t" + "[Links:] " + host.links.length.to_s
    end
  end
  
  def self.host_exists(domain)
    # Check if a host already exists before creating a new one
    exists = false
    ObjectSpace.each_object.select{|obj| obj.class == Host}.each do |host|
      if host.domain = domain
        exists = true
      end
    end
    return exists
  end
  
end