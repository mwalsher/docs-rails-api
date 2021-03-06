class Document < ApplicationRecord
  ADJECTIVES = ["Ablaze", "Abrupt", "Accomplished", "Active", "Adored", "Adulated", "Adventurous", "Affectionate", "Amused", "Amusing", "Animal-like", "Antique", "Appreciated", "Archaic", "Ardent", "Arrogant", "Astonished", "Audacious", "Authoritative", "Awestruck", "Beaming", "Bewildered", "Bewitching", "Blissful", "Boisterous", "Booming", "Bouncy", "Breathtaking", "Bright", "Brilliant", "Bubbling", "Calm", "Calming", "Capricious", "Celestial", "Charming", "Cheerful", "Cherished", "Chiaroscuro", "Chilled", "Comical", "Commanding", "Companionable", "Confident", "Contentment", "Courage", "Crazy", "Creepy", "Dancing", "Dazzling", "Delicate", "Delightful", "Demented", "Desirable", "Determined", "Devoted", "Dominant", "Dramatic", "Drawn out", "Dripping", "Dumbstruck", "Ebullient", "Elated", "Elegant", "Enchanted", "Energetic", "Enthusiastic", "Ethereal", "Exaggerated", "Exalted", "Expectant", "Expressive", "Exuberant", "Faint", "Fantastical", "Favorable", "Febrile", "Feral", "Feverish", "Fiery", "Floating", "Flying", "Folksy", "Fond", "Forgiven", "Forgiving", "Freakin' awesome", "Frenetic", "Frenzied", "Friendly. amorous", "From a distance", "Frosted", "Funny", "Furry", "Galloping", "Gaping", "Gentle", "Giddy", "Glacial", "Gladness", "Gleaming", "Gleeful", "Gorgeous", "Graceful", "Grateful", "Halting", "Happy", "Haunting", "Heavenly", "Hidden", "Honor", "Hopeful", "Hopping", "Humble", "Hushed", "Hypnotic", "Illuminated", "Immense", "Imperious", "Impudent", "Inflated", "Innocent", "Inspired", "Intimate", "Intrepid", "Jagged", "Joking", "Joyful", "Jubilant", "Kindly", "Kooky", "Keen", "Languid", "Laughable", "Lighthearted", "Limping", "Linear", "Lively", "Lofty", "Lovely", "Lulling", "Luminescent", "Lush", "Luxurious", "Magical", "Maniacal", "Manliness", "March-like", "Masterful", "Merciful", "Merry", "Mischievous", "Misty", "Modest", "Moonlit", "Mysterious", "Mystical", "Mythological", "Nebulous", "Nostalgic", "On fire", "Overstated", "Paganish", "Partying", "Perfunctory", "Perky", "Perplexed", "Persevering", "Pious", "Playful", "Pleasurable", "Poignant", "Portentous", "Posh", "Powerful", "Pretty", "Prickly", "Prideful", "Princesslike", "Proud", "Puzzled", "Queenly", "Questing", "Quiet", "Racy", "Ragged", "Regal", "Rejoicing", "Relaxed", "Reminiscent", "Repentant", "Reserved", "Resolute", "Ridiculous", "Ritualistic", "Robust", "Running", "Sarcastic", "Scampering", "Scoffing", "Scurrying", "Sensitive", "Serene", "Shaking", "Shining", "Silky", "Silly", "Simple", "Singing", "Skipping", "Smooth", "Sneaky", "Soaring", "Sophisticated", "Sparkling", "Spell-like", "Spherical", "Spidery", "Splashing", "Splendid", "Spooky", "Sprinting", "Starlit", "Starry", "Startling", "Successful", "Summery", "Surprised", "Sympathetic", "Tapping", "Teasing", "Tender", "Thoughtful", "Thrilling", "Tingling", "Tinkling", "Totemic", "Touching", "Tranquil", "Treasured", "Trembling", "Triumphant", "Twinkling", "Undulating", "Unruly", "Urgent", "Veiled", "Velvety", "Victorious", "Vigorous", "Virile", "Walking", "Wild", "Witty", "Wondering", "xiphophyllous", "xenophobic", "xylotomous", "Youthful", "Yielding", "Yeasty", "Zealous", "Zestful"]
  ANIMALS =["aardvark","albatross","alligator","alpaca","anaconda","ant","anteater","antelope","ape","armadillo","ass","baboon","badger","bandicoot","barracuda","basilisk","bat","bear","beaver","bee","bird","bison","black bear","boa constrictor","boar","bobcat","brown bear","buck","budgerigar","buffalo","bull","bunny","burro","butterfly","calf","camel","canary","caribou","cat","caterpillar","catfish","chameleon","chamois","cheetah","chicadee","chick","chicken","chimpanzee","chinchilla","chipmunk","civet","coati","cobra","cockatoo","cockroach","colt","cony","cormorant","cougar","cow","coyote","crab","crane","crocodile","crow","cub","deer","dingo","dodo","doe","dog","dogfish","dolphin","donkey","dormouse","dove","dragonfly","drake","dromedary","duck","duckbill","dugong","eagle","echidna","eel","egret","eland","elephant","elephant seal","elk","emu","ermine","ewe","falcon","fawn","ferret","filly","finch","fire ant","fish","flamingo","fly","foal","fox","frog","gander","gazelle","gecko","gemsbok","gerbil","gila monster","gilla monster","giraffe","gnu","goat","goose","gopher","gorilla","grizzly bear","ground hog","guanaco","guinea pig","gull","hamster","hare","hartebeest","hawk","hedgehog","hen","heron","hippopotamus","hog","hornet","horse","human","hummingbird","hyena","ibex","iguana","impala","jackal","jaguar","jellyfish","jerboa","joey","kangaroo","kid","killer whale","kingfisher","kinkajou","kitten","koala","komodo dragon","lamb","lark","lemming","lemur","leopard","lion","lizard","llama","lobster","locust","louse","lovebird","lynx","macaw","magpie","mallard","manatee","mandrill","manta ray","mare","marmoset","marmot","marten","meerkat","mink","mole","mongoose","monkey","moose","mosquito","mountain goat","mountain lion","mouse","mule","mule","musk deer","musk-ox","muskrat","mustang","mynah bird","narwhal","newt","newt","nightingale","ocelot","octopus","okapi","opossum","orangutan","orca","oryx","osprey","ostrich","otter","owl","ox","oyster","panda","panther","parakeet","parrot","partridge","peacock","peccary","pelican","penguin","pig","pigeon","piglet","platypus","polar bear","polecat","pony","porcupine","porpoise","prairie dog","pronghorn","pufferfish","puffin","puma","puppy","python","quail","rabbit","raccoon","ram","rat","rattlesnake","raven","reindeer","reptile","rhinoceros","roebuck","rooster","salamander","salmon","seahorse","seal","sea lion","seastar","shark","sheep","shrew","silver fox","skink","skunk","sloth","snail","snake","sparrow","spider","spider monkey","springbok","squid","squirrel","stag","stallion","starfish","steer","sting ray","stinkbug","stork","swallow","swan","tadpole","tapir","tern","tiger","toad","tortoise","turkey","turtle","vicuna","vulture","wallaby","wallaroo","walrus","warthog","wasp","waterbuck","water buffalo","weasel","whale","wildcat","wildebeest","wolf","wolverine","wombat","woodchuck","woodpecker","worm","Xenops", "Xenus", "Xantus", "Xenopodeidon","yak","zebra"]
  URL_BASE = "http://localhost:3001?doc="

  def self.create_name
    adjectives = ADJECTIVES.group_by{ |adjective| adjective[0].downcase }
    animals = ANIMALS.group_by{ |animal| animal[0].downcase }
    letter = ('a'..'z').to_a[rand(0..25)]
    "#{adjectives[letter][rand(0..adjectives[letter].length - 1)].titleize} #{animals[letter][rand(0..animals[letter].length - 1)].titleize}" rescue ["Dwarfly Dragon", "Magic Moose", "Poor Panda", "Creative Centaur"][rand(0..3)]
  end

  def self.generate_url
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    "#{(0...15).map { o[rand(o.length)] }.join}"
  end

  def url_share
    URL_BASE + self.url
  end

  def send_message(phone_number)
    # TWILIO_NUMBER: '7782007426'
    # TWILIO_AUTH_TOKEN: '42609622ed644e6d5098bf9f03e0ead3'
    # TWILIO_ACCOUNT_SID: 'AC20cf858bc76b1c93b8c10e44f118c4ce'
    # put in local_env.yml

    @twilio_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

    message = @client.account.messages.create(
      :from => @twilio_number,
      :to => "1#{phone_number}".to_i,
      :body => self.url_share
    )
    puts "SMS sent to #{message.to} :)"
  end
end
