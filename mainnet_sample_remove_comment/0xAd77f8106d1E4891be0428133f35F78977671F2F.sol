 

 
pragma solidity ^0.8.0;




error YoureNotTheOwnerHomie();
error SorryYouCantAbandonOwnershipToTheZeroAddress();

contract goodblocksGen0
{
    constructor()
    {
        _Owner = msg.sender;
    }
    struct GoodBlock
    {
        uint8 pixelSizeIndex;
        uint8 symmetryIndex;
        uint8 colorGroupIndex;
        uint8 paletteIndex;
        bool isDarkBlock; 
        uint16 tokenIndex;
        bytes3 labelColor;
        string blockDNA;
    }
    uint8[5] private PixelSizes = [5,8,10,20,25];
    uint8[5] private PixelSizeHalf = [3,4,5,10,13];
    uint8[5] private PixelSizePadding = [1,2,2,3,5];
    uint8[5] private PixelSizePercents = [20,0,10,5,4];
    uint8[] private PixelSizeWeights = [25,15,20,15,25];
    uint8[] private BlockSymmetryWeights = [40,25,15,15,4,1];
    uint8[] private ColorGroupWeights = [30,10,20,10,25,30,15];
    uint8[] private PixelColorWeights = [65,20,10,5];
    uint8[] private PixelColorWeightsBiggins1 = [20,35,30,15];
    uint8[] private PixelColorWeightsBiggins2 = [40,30,20,10];
    string private GenerationDescription = "goodblocks generation 0 (gen0) is made up of random pixel images. head to goodblocks.io to learn more about the art process!";
    function updateGenerationDescription(string memory _newDescription) external
    {
        if(msg.sender != _Owner) revert YoureNotTheOwnerHomie();
        GenerationDescription = _newDescription;
    }
    string[5] private PixelSizeNames = ["Biggins", "Great Eight", "10 out of 10", "Score", "XXV"];
    string[8] private PixelEightPercents = ["0%", "12.5%", "25%", "37.5%", "50%", "62.5%", "75%", "87.5%"];
    string[6] private BlockSymmetryNames = ["X=0", "Y=0", "Y=X", "Y=-X", "Flipper", "Chaos"];
    string[6] private BlockSymmetryStrings = 
    [
        '(1000,0) scale(-1,1)',  
        '(0,1000) scale(1,-1)',  
        '(1000, 0) scale(-1,1) rotate(-90,500,500)',  
        '(1000, 0) scale(-1,1) rotate(90,500,500)',  
        '(1000,1000) scale(-1,-1)',  
        '(0,0) scale(1,1)'  
    ];
    string private constant LabelFlags =
        "01000101"   
        "11111111"   
        "11000010"   
        "00000110"   
        "10100011"   
        "01111100"   
        "10111000";  

    string[7] private ColorGroupNames = ["Joy", "Night", "Cosmos", "Earth", "Arctic", "Serenity", "Twilight"];
    string[56] private ColorPalettes = 
    [
        "#FDFF8F;#A8ECE7;#F4BEEE;#D47AE8",  
        "#FD6F96;#FFEBA1;#95DAC1;#6F69AC",
        "#FFDF6B;#FF79CD;#AA2EE6;#23049D",
        "#95E1D3;#EAFFD0;#FCE38A;#FF75A0",
        "#FFCC29;#F58634;#007965;#00AF91",
        "#998CEB;#77E4D4;#B4FE98;#FBF46D",
        "#EEEEEE;#77D970;#172774;#FF0075",
        "#005F99;#FF449F;#FFF5B7;#00EAD3",
        "#0B0B0D;#474A56;#929AAB;#D3D5FD",  
        "#07031A;#4F8A8B;#B1B493;#FFCB74",
        "#2E3A63;#665C84;#71A0A5;#FAB95B",
        "#000000;#226089;#4592AF;#E3C4A8",
        "#1B1F3A;#53354A;#A64942;#FF7844",
        "#1a1a1a;#153B44;#2D6E7E;#C6DE41",
        "#0F0A3C;#07456F;#009F9D;#CDFFEB",
        "#130026;#801336;#C72C41;#EE4540",
        "#111D5E;#C70039;#F37121;#C0E218",  
        "#02383C;#230338;#ED5107;#C70D3A",
        "#03C4A1;#C62A88;#590995;#150485",
        "#00A8CC;#005082;#000839;#FFA41B",
        "#E94560;#0F3460;#16213E;#1A1A2E",
        "#D2FAFB;#FE346E;#512B58;#2C003E",
        "#706C61;#E1F4F3;#FFFFFF;#333333",
        "#FAF7F2;#2BB3C0;#161C2E;#EF6C35",
        "#FFFBE9;#E3CAA5;#CEAB93;#AD8B73",  
        "#A09F57;#C56824;#CFB784;#EADEB8",
        "#E3D0B9;#E1BC91;#C19277;#62959C",
        "#E9C891;#8A8635;#AE431E;#D06224",
        "#83B582;#D6E4AA;#FFFFC5;#F0DD92",
        "#303E27;#B4BB72;#E7EAA8;#F6FAF7",
        "#A8896C;#F1E8A7;#AED09E;#61B292",
        "#F4DFBA;#EEC373;#CA965C;#876445",
        "#42C2FF;#85F4FF;#B8FFF9;#EFFFFD",  
        "#E8F0F2;#A2DBFA;#39A2DB;#053742",
        "#3E64FF;#5EDFFF;#B2FCFF;#ECFCFF",
        "#D1FFFA;#4AA9AF;#3E31AE;#1C226B",
        "#F7F3F3;#C1EAF2;#5CC2F2;#191BA9",
        "#F3F3F3;#303841;#3A4750;#2185D5",
        "#769FCD;#B9D7EA;#D6E6F2;#F7FBFC",
        "#3D6CB9;#00D1FF;#00FFF0;#FAFAF6",
        "#99FEFF;#94DAFF;#94B3FD;#B983FF",  
        "#E5707E;#E6B566;#E8E9A1;#A3DDCB",
        "#6892D5;#79D1C3;#C9FDD7;#F8FCFB",
        "#6C5B7B;#C06C84;#F67280;#F8B195",
        "#30475E;#BA6B57;#F1935C;#E7B2A5",
        "#FFEBD3;#264E70;#679186;#FFB4AC",
        "#6DDCCF;#94EBCD;#FFEFA1;#FFCB91",
        "#D8EFF0;#B0E0A8;#F0F69F;#F3C1C6",
        "#35477D;#6C5B7B;#C06C84;#F67280",  
        "#F6C065;#55B3B1;#AF0069;#09015F",
        "#470D21;#9C0F48;#D67D3E;#F9E4D4",
        "#001F52;#A10054;#FF8D68;#FFECBA",
        "#FF6C00;#A0204C;#23103A;#282D4F",
        "#FFF9B2;#ECAC5D;#B24080;#3F0713",
        "#FFE98A;#C84771;#61105E;#280B45",
        "#EDE862;#FA9856;#F27370;#22559C"
    ];
    string private constant SvgHeader = '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'
        ' preserveAspectRatio="xMinYMin" shape-rendering="crispEdges" viewBox="0 0 1000 1000">';
    string[] private svgBody = 
    [
         
        '<g id="goodblock',
         
        '"><g id="bigBlock"><rect id="background" width="100%" height="100%" fill="',
         
        '" /></g><g id="littleBlocks"><g id="yetAnotherGroupForAnimation"><g id="ogBlocks"><g id="colorOneGroup" fill="',
         
        '">',
         
        '</g><g id="colorTwoGroup" fill="',
         
        '">',
         
        '</g><g id="colorThreeGroup" fill="',
         
        '">',
         
        '</g></g><g id="poserBlocks"><use xlink:href="#ogBlocks" transform="translate',
         
        '"/></g></g></g></g>'
        '<text x="10%" y="96%" text-anchor="middle" fill="#',
         
        '" font-size="18" font-family="Courier New">',
         
        '</text>'
        '<!--lilNudge-->'
        '<animateTransform'
           ' id="lilNudgeA" xlink:href="#littleBlocks"'
           ' attributeName="transform" type="rotate"'
           ' values="0 500 500;15 500 500;0 500 500;"'
           ' begin="colorOneGroup.click" dur=".5"/>'
        '<animate'
           ' xlink:href="#background" attributeName="fill"'
           ' values="',
         
        '" begin="colorOneGroup.click" dur=".5"/>'
        '<!--letsGoForASpin-->'
        '<animate xlink:href="#background" attributeName="fill" values="',
         
        '" begin="colorTwoGroup.click" dur="2"/>'
        '<animateTransform xlink:href="#yetAnotherGroupForAnimation"'
            ' attributeName="transform" begin="colorTwoGroup.click"'
            ' type="rotate" values="0 500 500;360 500 500" dur="2"/>'
        '<animateTransform xlink:href="#littleBlocks"'
            ' attributeName="transform" begin="colorTwoGroup.click"'
            ' values="0 0;-1000 0" dur=".5"/>'
        '<animateTransform xlink:href="#littleBlocks"'
            ' attributeName="transform" begin="colorTwoGroup.click+.5"'
            ' values="1000 0;-1000 0" dur="1"/>'
        '<animateTransform xlink:href="#littleBlocks"'
            ' attributeName="transform" begin="colorTwoGroup.click+1.5"'
            ' values="1000 0;0 0" dur=".5"/>'
        '<!--whatTheHeckIsHappening?-->'
        '<animate xlink:href="#background"'
            ' attributeName="fill" begin="colorThreeGroup.click"'
            ' values="',
         
            '" keyTimes="0;.01;.99;1" dur="10"/>'
        '<animateTransform xlink:href="#yetAnotherGroupForAnimation"'
            ' attributeName="transform" begin="colorThreeGroup.click + .02"'
            ' type="translate" values="0 0;0 50;0 250;0 150;0 0;"'
            ' keyTimes="0;.002;.5;.98;1" dur="9.98s"/>'
        '<animateTransform xlink:href="#colorOneGroup"'
            ' attributeName="transform" additive="sum" type="scale"'
            ' begin="colorThreeGroup.click" values="1;.4;.3;.4;1"'
            ' keyTimes="0;.02;.5;.98;1" dur="10s"/>'
        '<animateTransform xlink:href="#colorOneGroup"'
            ' attributeName="transform" additive="sum" type="rotate"'
            ' begin="colorThreeGroup.click + .02" values="0 1000 1000; 360 1000 1000"'
            ' dur="9.98s"/>'
        '<animateTransform xlink:href="#colorTwoGroup"'
            ' attributeName="transform" additive="sum" type="scale"'
            ' begin="colorThreeGroup.click" values="1;.6;.5;.6;1"'
            ' keyTimes="0;.02;.5;.98;1" dur="10s"/>'
        '<animateTransform xlink:href="#colorTwoGroup"'
            ' attributeName="transform" additive="sum" type="rotate"' 
            ' begin="colorThreeGroup.click + .02" values="0 500 600;-360 500 600"'
            ' dur="9.98s"/>'
        '<animateTransform xlink:href="#colorThreeGroup"'
            ' attributeName="transform" additive="sum" type="scale"'
            ' begin="colorThreeGroup.click" values="1;.8;.6;.4;1"'
            ' keyTimes="0;.01;.5;.98;1" dur="10s"/>'
        '<animateTransform xlink:href="#colorThreeGroup"'
            ' attributeName="transform" additive="sum" type="rotate"'
            ' begin="colorThreeGroup.click + .02" values="0 500 500;360 500 500"'
            ' dur="9.98s"/>'
    '</svg>'
    ];
    function updateSvgBody(uint256 _index, string memory _newString) external returns (string[] memory)
    {
        if(msg.sender != _Owner) revert YoureNotTheOwnerHomie();
        svgBody[_index] = _newString;
        return svgBody;
    }
    function substring(string memory str, uint256 startIndex, uint256 endIndex) private pure returns (string memory)
    {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++)
        {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
    function random(string memory _input) private pure returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(_input)));
    }
    function getWeightedItem(uint8[] memory weightArray, uint256 i) private pure returns (uint8)
    {
        uint256 index = 0;
        uint256 j = weightArray[0];
        while (j <= i)
        {
            index++;
            j += weightArray[index];
        }
        return uint8(index);
    }
    function tokenToGoodblock(uint256 _tokenId) public view returns(GoodBlock memory)
    {
        GoodBlock memory goodblock;
         
        goodblock.tokenIndex = uint16(_tokenId);
         
        goodblock.pixelSizeIndex = getWeightedItem(PixelSizeWeights, random(Strings.toString(_tokenId + 20)) % 100);
         
        goodblock.symmetryIndex = getWeightedItem(BlockSymmetryWeights, random(Strings.toString(_tokenId + 22)) % 100) ;
         
        goodblock.colorGroupIndex = getWeightedItem(ColorGroupWeights, random(Strings.toString(_tokenId + 1)) % 140);
         
        goodblock.paletteIndex = uint8(random(string(abi.encodePacked("Wth?", Strings.toString(_tokenId + 4)))) % 8);

        string memory blockDNA =  string(abi.encodePacked(
            Strings.toString(_tokenId),
            "_",
            Strings.toString(goodblock.pixelSizeIndex),
            "_",
            Strings.toString(goodblock.symmetryIndex),
            "_",
            Strings.toString(goodblock.colorGroupIndex),
            "_",
            Strings.toString(goodblock.paletteIndex)
        ));

         
        if (keccak256(abi.encodePacked(substring(LabelFlags, (goodblock.colorGroupIndex * 8 + goodblock.paletteIndex), (goodblock.colorGroupIndex * 8 + goodblock.paletteIndex)+1))) == keccak256("1"))
        {
            goodblock.labelColor = bytes3("fff");
        } else
        {
            goodblock.labelColor = bytes3("000");
        }

         
        if(_tokenId < 2133 || _tokenId > 6120)
        {
            goodblock.isDarkBlock = false;
            goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_0"));
            return goodblock;
        }

         
        if(_tokenId > 2132 && _tokenId < 3789)
        {
             
            uint tokenDivY = uint(_tokenId/91);
            uint tokenModX = _tokenId%91;
            
             
            if(tokenDivY < 28)
            {
                if(tokenModX < 40 || tokenModX > 44)
                {
                    goodblock.isDarkBlock = false;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_0"));
                    return goodblock;
                } else
                {
                    goodblock.isDarkBlock = true;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_1"));
                    goodblock.labelColor = bytes3("fff");
                    return goodblock;
                }
            }

             
            if(tokenModX > 29 && tokenModX < 62)
            {
                tokenDivY = tokenDivY - 28;
                if(keccak256(abi.encodePacked(substring(d, tokenDivY*32+tokenModX-30, tokenDivY*32+tokenModX-30 + 1))) == keccak256("1"))
                {
                    goodblock.isDarkBlock = true;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_1"));
                    goodblock.labelColor = bytes3("fff");
                    return goodblock;
                }else
                {
                    goodblock.isDarkBlock = false;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_0"));
                    return goodblock;
                }
            }
        }
         
        else if(_tokenId > 4077 && _tokenId < 6121)
        {
             
            uint tokenDivY = uint(_tokenId/91);
            uint tokenModX = _tokenId%91;
            
             
             
            if(tokenDivY < 49)
            {
                if(tokenModX < 74 || tokenModX > 78)
                {
                    goodblock.isDarkBlock = false;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_0"));
                    return goodblock;
                } else
                {
                    goodblock.isDarkBlock = true;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_1"));
                    goodblock.labelColor = bytes3("fff");
                    return goodblock;
                }
            }
             
            else if(tokenDivY > 62)
            {
                if(tokenModX > 27)
                {
                    goodblock.isDarkBlock = false;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_0"));
                    return goodblock;
                }
            }

             
            if(tokenModX > 12 && tokenModX < 79)
            {
                tokenDivY = tokenDivY - 49;
                if(keccak256(abi.encodePacked(substring(g, tokenDivY*66+tokenModX-13, tokenDivY*66+tokenModX-13 + 1))) == keccak256("1"))
                {
                    goodblock.isDarkBlock = true;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_1"));
                    goodblock.labelColor = bytes3("fff");
                    return goodblock;
                }else
                {
                    goodblock.isDarkBlock = false;
                    goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_0"));
                    return goodblock;
                }
            }
        }
        
        goodblock.isDarkBlock = false;
        goodblock.blockDNA = string(abi.encodePacked(blockDNA,"_0"));
        return goodblock;
    }
    function goodblockToSVG(GoodBlock memory _goodblock) private view returns(string memory)
    {
         
        string memory rectPercent;
        string[] memory pixelPercents = new string[](PixelSizes[_goodblock.pixelSizeIndex]);
 
         
        if(PixelSizes[_goodblock.pixelSizeIndex] == 8)
        {
             
            rectPercent = "12.5%";
             
            for(uint256 i=0; i<PixelSizes[_goodblock.pixelSizeIndex]; i++)
            {
                pixelPercents[i] = PixelEightPercents[i];
            }

        } else
        {
             
            rectPercent = string(abi.encodePacked(Strings.toString(PixelSizePercents[_goodblock.pixelSizeIndex]), "%"));
             
            for(uint256 i = 0; i<PixelSizes[_goodblock.pixelSizeIndex]; i++) 
            {
                pixelPercents[i] = string(abi.encodePacked(Strings.toString(i*PixelSizePercents[_goodblock.pixelSizeIndex]), "%"));
            }
        }

         
        string[3] memory colorGroupRectangles;
        uint256 tempColorGroupIndex;
        string memory blockMap;

         
         
         
         
         
         

         
         
        for (uint y=0; y<PixelSizes[_goodblock.pixelSizeIndex]; y++)
        {
             
            if(y < PixelSizePadding[_goodblock.pixelSizeIndex] || 
                PixelSizes[_goodblock.pixelSizeIndex]-y < PixelSizePadding[_goodblock.pixelSizeIndex] + 1)
            {
                continue; 
            }

             
            if(_goodblock.symmetryIndex == 1)
            {
                if((y+1) > PixelSizeHalf[_goodblock.pixelSizeIndex])
                {
                    continue;
                }
            }

             
            if(_goodblock.symmetryIndex == 2 && _goodblock.tokenIndex % 2 == 0)
            {
                if((y+1) > PixelSizeHalf[_goodblock.pixelSizeIndex])
                {
                    continue;
                }
            }

             
            if(_goodblock.symmetryIndex == 3 && _goodblock.tokenIndex % 2 == 0)
            {
                if((y+1) < PixelSizeHalf[_goodblock.pixelSizeIndex])
                {
                    continue;
                }
            }

             
            for (uint x=0; x<PixelSizes[_goodblock.pixelSizeIndex]; x++)
            {
                 
                if(x < PixelSizePadding[_goodblock.pixelSizeIndex] ||
                    PixelSizes[_goodblock.pixelSizeIndex]-x < PixelSizePadding[_goodblock.pixelSizeIndex] + 1)
                {
                    continue;
                }

                 
                if(_goodblock.symmetryIndex == 0 || _goodblock.symmetryIndex == 4)
                {
                    if((x+1) > PixelSizeHalf[_goodblock.pixelSizeIndex])
                    {
                        continue;
                    }
                }            
                 
                else if(_goodblock.symmetryIndex == 2)
                {
                    if(_goodblock.tokenIndex % 2 == 0)
                    {
                        if((x+1) > PixelSizeHalf[_goodblock.pixelSizeIndex])
                        {
                            continue;
                        }

                    } else
                    {
                        if(x > (PixelSizes[_goodblock.pixelSizeIndex] - y - 1))
                        {
                            continue;
                        }
                    }    
                }
                 
                else if(_goodblock.symmetryIndex == 3)
                {
                    if(_goodblock.tokenIndex % 2 == 0)
                    {
                        if((x+1) > PixelSizeHalf[_goodblock.pixelSizeIndex]
                        )
                        {
                            continue;
                        }
                    } else
                    {
                        if(x < y + 1)
                        {
                            continue;
                        }
                    }
                }
                
                tempColorGroupIndex = getWeightedItem(PixelColorWeights, random(string(abi.encodePacked(_goodblock.blockDNA, Strings.toString(x*24 + y*22 + _goodblock.tokenIndex)))) % 100);

                 
                if(_goodblock.pixelSizeIndex == 0)
                {
                    if(_goodblock.tokenIndex % 4 == 0)
                    {
                        tempColorGroupIndex = getWeightedItem(PixelColorWeightsBiggins1, random(string(abi.encodePacked(_goodblock.blockDNA, Strings.toString(x*13 + y*4 + 13 + _goodblock.tokenIndex)))) % 100);
                    } else if(_goodblock.tokenIndex % 2 == 0)
                    {
                        tempColorGroupIndex = getWeightedItem(PixelColorWeightsBiggins2, random(string(abi.encodePacked(_goodblock.blockDNA, Strings.toString(x*13 + y*4 + 13 + _goodblock.tokenIndex)))) % 100);
                    }
                }

                 
                if(tempColorGroupIndex == 0)
                {
                    blockMap = string(abi.encodePacked(blockMap, "0"));
                    continue;
                }

                blockMap = string(abi.encodePacked(blockMap, "1"));

                 
                colorGroupRectangles[tempColorGroupIndex-1] = string(abi.encodePacked(
                    colorGroupRectangles[tempColorGroupIndex-1],
                    '<rect x="',
                    pixelPercents[x],
                    '" y="',
                    pixelPercents[y]
                ));
                colorGroupRectangles[tempColorGroupIndex-1] = string(abi.encodePacked(  
                    colorGroupRectangles[tempColorGroupIndex-1],  
                    '" width="',
                    rectPercent,
                    '" height="',
                    rectPercent,
                    '"/>'
                ));

                 
            }
        }
        
        _goodblock.blockDNA = string(abi.encodePacked(_goodblock.blockDNA, "_", blockMap));

        string memory animatedBG2;

         
        string memory bgColor = substring(ColorPalettes[(_goodblock.colorGroupIndex * 8 + _goodblock.paletteIndex)], 0, 7);
        
        if(_goodblock.isDarkBlock)
        {
             
            animatedBG2 = string(abi.encodePacked(
                '#000;',
                bgColor,';',
                bgColor,';',
                '#000'
            ));
             
            bgColor = "#000";
        } else
        {
             
            animatedBG2 = string(abi.encodePacked(
                bgColor,';',
                '#000;',
                '#000;',
                bgColor
            ));
        }

         
         
         
         
         
         
         
         
         
         
         
         
         

        string memory blockSVG = string(abi.encodePacked(
            SvgHeader,
            svgBody[0],
            Strings.toString(uint256(_goodblock.tokenIndex)),
            svgBody[1],
            bgColor,
            svgBody[2]
        ));

        blockSVG = string(abi.encodePacked(
            blockSVG,
            substring(ColorPalettes[(_goodblock.colorGroupIndex * 8 + _goodblock.paletteIndex)], 8, 15),
            svgBody[3],
            colorGroupRectangles[0],
            svgBody[4]
        ));
        
        blockSVG = string(abi.encodePacked(
            blockSVG,
            substring(ColorPalettes[(_goodblock.colorGroupIndex * 8 + _goodblock.paletteIndex)], 16, 23),
            svgBody[5],
            colorGroupRectangles[1]
        ));
        
        blockSVG = string(abi.encodePacked(
            blockSVG,
            svgBody[6],
            substring(ColorPalettes[(_goodblock.colorGroupIndex * 8 + _goodblock.paletteIndex)], 24, 31),
            svgBody[7]
        ));

        blockSVG = string(abi.encodePacked(
            blockSVG,
            colorGroupRectangles[2],
            svgBody[8],
            BlockSymmetryStrings[_goodblock.symmetryIndex]
        ));
        
        blockSVG = string(abi.encodePacked(
            blockSVG,
            svgBody[9],
            _goodblock.labelColor,
            svgBody[10],
            ColorGroupNames[_goodblock.colorGroupIndex],
            ' #',
            Strings.toString(_goodblock.tokenIndex)
        ));
        
        blockSVG = string(abi.encodePacked(
            blockSVG,
            svgBody[11],
            ColorPalettes[(_goodblock.colorGroupIndex * 8 + _goodblock.paletteIndex)],
            svgBody[12]
        ));

        blockSVG = string(abi.encodePacked(
            blockSVG,
            ColorPalettes[(_goodblock.colorGroupIndex * 8 + _goodblock.paletteIndex)],
            svgBody[13],
            animatedBG2,
            svgBody[14]
        ));

        return blockSVG;        
    }
    function blockToMetadata(GoodBlock memory _goodblock) private view returns(string memory)
    {
        string memory metadata = string(abi.encodePacked(
            '{"trait_type": "Pixel Size", "value":"',
            PixelSizeNames[_goodblock.pixelSizeIndex],
            '"},{"trait_type": "Symmetry", "value":"',
            BlockSymmetryNames[_goodblock.symmetryIndex],
            '"},{"trait_type": "Color Group", "value":"',
            ColorGroupNames[_goodblock.colorGroupIndex],
            '"},{"trait_type": "Palette Index", "value":"',
            Strings.toString(_goodblock.paletteIndex),
            '"},'
        ));

        if(_goodblock.isDarkBlock)
        {
            metadata = string(abi.encodePacked(
                metadata,
                '{"trait_type": "Special Trait", "value":"Do Good"},'
            ));
        } else
        {
            metadata = string(abi.encodePacked(
                metadata,
                '{"trait_type": "Special Trait", "value":"None"},'
            ));
        }

        return metadata;
    }
    function tokenGenURI(uint256 _tokenId, string memory _tokenMetadata, string memory _tokenAttributes) public view returns(string memory)
    {
         
        GoodBlock memory goodblock = tokenToGoodblock(_tokenId);        
         
        string memory goodblockSVG = string(Base64.encode(bytes(goodblockToSVG(goodblock))));
         
        string memory goodblockMetadata = blockToMetadata(goodblock);
         
        string memory tokenUri = string(abi.encodePacked(
            '{"name":"',
            ColorGroupNames[goodblock.colorGroupIndex],
            ' #',
            Strings.toString(_tokenId),
            '","description":"',
            GenerationDescription,
            '","DNA":"',
            goodblock.blockDNA,
            '",',
            _tokenMetadata,
            ',"attributes":[',
            goodblockMetadata,
            _tokenAttributes,
            '],"image":"data:image/svg+xml;base64,',
            goodblockSVG,
            '"}'
        ));       
        
        return string(abi.encodePacked("data:application/json;base64,", string(Base64.encode(bytes(tokenUri)))));
    }
    string private constant d = "0000111110111110000001111111000000111111111111100001111111111100011111111111111000111111111111101111111111111110011111111111111111111100011111100111111000111111111110000011111001111100000111111111100000111110011111000001111111111000001111100111110000011111111110000011111001111100000111111111110001111110011111100011111111111111111111100111111111111111011111111111111000111111111111100011111111111110000111111111110000011111101111100000011111110000";
    string private constant g = "000011110011111000000111111100000000001111111000000000011111011111001111111111111000011111111111000000111111111110000001111111111111011111111111111000111111111111100001111111111111000011111111111111111111111111111001111111111111110011111111111111100111111111111111111111000111111001111110001111110011111100011111100111111000111111111110000011111001111100000111110011111000001111100111110000011111111110000011111001111100000111110011111000001111100111110000011111111110000011111001111100000111110011111000001111100111110000011111111110000011111001111100000111110011111000001111100111110000011111111111000111111001111110001111110011111100011111100111111000111111011111111111111001111111111111110011111111111111100111111111111111001111111111111000111111111111100001111111111111000011111111111111000111111011111000011111111111000000111111111110000001111111111111000000000011111000000111111100000000001111111000000000111111011111011100000111111000000000000000000000000000000000000000000000000000011111111111111000000000000000000000000000000000000000000000000000011111111111110000000000000000000000000000000000000000000000000000011111111111100000000000000000000000000000000000000000000000000000001111111110000000000000000000000000000000000000000000000000000000";
    address public _Owner;
    function transferOwnership(address _newOwner) external 
    {
        if(msg.sender != _Owner) revert YoureNotTheOwnerHomie();
        if(_newOwner == address(0)) revert SorryYouCantAbandonOwnershipToTheZeroAddress();
        _Owner = _newOwner;
    }
}

 
 

pragma solidity ^0.8.0;

 
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

     
    function toString(uint256 value) internal pure returns (string memory) {
         
         

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

     
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

     
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

 
 

pragma solidity ^0.8.0;

 
library Base64 {
     
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

     
    function encode(bytes memory data) internal pure returns (string memory) {
         
        if (data.length == 0) return "";

         
        string memory table = _TABLE;

         
         
         
         
         
         
        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
             
            let tablePtr := add(table, 1)

             
            let resultPtr := add(result, 32)

             
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                 
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                 
                 
                 
                 
                 
                 
                 

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)  

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)  

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)  

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)  
            }

             
             
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}