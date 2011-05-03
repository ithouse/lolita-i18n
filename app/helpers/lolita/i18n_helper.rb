module Lolita
  module I18nHelper

    def translation_tree(data)
      tree={}
      data.keys.sort.each do |key|
        parts=key.to_s.split(".")
        put_in_tree(tree,parts,data[key],key)
      end
      
      tree
    end

    def put_in_tree(tree,parts,value,full_path)
      last_tree=tree
      last_index=parts.size-1
      parts.each_with_index do |phrase,index|
        if index==last_index
          unless last_tree[phrase]
            last_tree[phrase]={:"__value__"=>{:value=>ActiveSupport::JSON.decode(value),:path=>full_path}}
          else
            last_tree[phrase][:__value__]={:value=>ActiveSupport::JSON.decode(value),:path=>full_path}
          end
          
        else
          last_tree[phrase]||={}
          last_tree=last_tree[phrase]
        end
      end
    end

  end
end