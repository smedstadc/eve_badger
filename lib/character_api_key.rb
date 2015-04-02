module EveTooper
  class CharacterKey < EveTooper::AccountKey
    def initialize_hook(args)
      @characterid = args[:characterid]
    end

    private
    def params
      "?keyid=#{@keyid}&vcode=#{@vcode}&characterid=#{@characterid}"
    end
  end
end