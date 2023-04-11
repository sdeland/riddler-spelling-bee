%% Solution to the Riddler Spelling Bee Puzzle
% https://fivethirtyeight.com/features/can-you-solve-the-vexing-vexillology/

% Word list
s = webread('https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt');
word = split(s,newline);
word(contains(word,"s")) = []; % remove words with "s" in them
t = table(word);

% We only get points for words with 4 or more characters, remove other
% words
t.numChars = strlength(t.word);
t = t(t.numChars>=4,:);

% Get unique list of letters in each word
t.letterset = cellfun(@(s)unique(s),t.word,'UniformOutput',false);
t.numUniqueChars = strlength(t.letterset);

% We can only make words with up to 7 unique characters
t = t(t.numUniqueChars<=7,:);

%% Points per Word
% Points from word length
pointsWordLength = t.numChars;
pointsWordLength(t.numChars==4) = 1;

% Bonus points for using all letters
pointsBonus = 7*(t.numUniqueChars==7);

% Total points
t.points = pointsWordLength+pointsBonus;

%% Calculate Points for All Possible Boards

% Numeric representation of unique letters
lettersetDec = cellfun(@word2dec,t.letterset);
t.lettersetDec = lettersetDec;

% Numeric representation of possible boards
boardOptions = unique(t.letterset(t.numUniqueChars==7));
boards = cellfun(@word2dec,boardOptions);

% Find words in boards
fprintf('Calculating points for all possible boards...\n');
numBoards = size(boards,1);
scores = zeros(numBoards,1);
dec = zeros(numBoards,1);
for i = 1:numBoards
    idx = bitor(boards(i),lettersetDec)==boards(i); % Where the magic happens
    scores(i) = sum(t.points(idx));
end

%%
fprintf('Choosing a center tile...\n');
results = table(boards,scores);
results(results.scores==0,:) = [];
results = sortrows(results,'scores','descend');

head(results)

%% Find the best center letter
% Start with the highest possible scoring board, search through all
% possible center letters for that board, and find the center letter with
% highest score.  Stop once we have gone through enough rows of the results
% table that we can guarantee we won't find a higher-scoring board.
bestScore = 0;
row = 1;
upperLimitScore = results.scores(row);
while bestScore < upperLimitScore
    letters = dec2word(results.boards(row));
    tsubidx = bitor(results.boards(row),lettersetDec)==results.boards(row);
    tsub = t(tsubidx,:);
    for centerLetterIdx = 1:7
        centerLetter = letters(centerLetterIdx);
        validWords = contains(tsub.word,centerLetter);
        score = sum(tsub.points(validWords));
        if score > bestScore
            bestScore = score;
            bestLetters = letters;
            bestCenterLetter = centerLetter;
        end
    end
    row=row+1;
    upperLimitScore = results.scores(row);
end
fprintf('Letters: %s\tCenter Letter: %s\tScore:%d\n',bestLetters,bestCenterLetter,bestScore);

%% Helpers
% Convert a word to a binary representation
function dec = word2dec(word)
	powers= 2.^(31:-1:0);
    dec = sum(powers(word-96));
end

% Convert a binary representation to a word
function word = dec2word(dec)
    letters = 'a':'z';
    lettersIdx = dec2bin(dec,32)=='1';
    word = letters(lettersIdx);
end

