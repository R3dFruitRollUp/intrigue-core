class IntrigueApp < Sinatra::Base

    ###                      ###
    ### Analysis Views       ###
    ###                      ###

    get '/:project/analysis/domains' do
      length = params["length"].to_i
      @domains = Intrigue::Model::Entity.scope_by_project(@project_name).where(:type => "Intrigue::Entity::DnsRecord").sort_by{|x| x.name }
      @tlds = @domains.map { |d| d.name.split(".").last(length).join(".") }.group_by{|e| e}.map{|k, v| [k, v.length]}.sort_by{|k,v| v}.reverse.to_h

      erb :'analysis/domains'
    end

    get '/:project/analysis/services' do
      @services = Intrigue::Model::Entity.scope_by_project(@project_name).where(:type => "Intrigue::Entity::NetworkService").sort_by{|x| x.name }
      erb :'analysis/services'
    end

    get '/:project/analysis/systems' do
      @entities = Intrigue::Model::Entity.scope_by_project(@project_name).where(:type => "Intrigue::Entity::IpAddress").sort_by{|x| x.name }

      # Grab providers & analyse
      @providers = {}
      @entities.each do |e|
        pname = e.get_detail("provider") || "None"

        pname = "None" if pname.length == 0

        if @providers[pname]
          @providers[pname] << e
        else
          @providers[pname] = [e]
        end
      end

      # Grab providers & analyse
      @os = {}
      @entities.each do |e|
        # Get the key for the hash
        if e.get_detail("os").to_a.first
          os_string = e.get_detail("os").to_a.first.match(/(.*)(\ \(.*\))/)[1]
        else
          os_string = "None"
        end

        # Set the value
        if @os[os_string]
          @os[os_string] << e
        else
          @os[os_string] = [e]
        end
      end

      erb :'analysis/systems'
    end


    get '/:project/analysis/websites' do
      selected_entities = Intrigue::Model::Entity.scope_by_project(@project_name).where(:type => "Intrigue::Entity::Uri").order(:name)

      ## Filter by type
      alias_group_ids = selected_entities.map{|x| x.alias_group_id }.uniq
      @alias_groups = Intrigue::Model::AliasGroup.where(:id => alias_group_ids)

      erb :'analysis/websites'
    end
end
