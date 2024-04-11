
 

 


 

pragma solidity ^0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 


 

pragma solidity ^0.8.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _transferOwnership(_msgSender());
    }

     
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

 


 

pragma solidity ^0.8.0;

 
library Math {
    enum Rounding {
        Down,  
        Up,  
        Zero  
    }

     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a & b) + (a ^ b) / 2;
    }

     
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

     
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
             
             
             
            uint256 prod0;  
            uint256 prod1;  
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

             
            if (prod1 == 0) {
                return prod0 / denominator;
            }

             
            require(denominator > prod1);

             
             
             

             
            uint256 remainder;
            assembly {
                 
                remainder := mulmod(x, y, denominator)

                 
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

             
             

             
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                 
                denominator := div(denominator, twos)

                 
                prod0 := div(prod0, twos)

                 
                twos := add(div(sub(0, twos), twos), 1)
            }

             
            prod0 |= prod1 * twos;

             
             
             
            uint256 inverse = (3 * denominator) ^ 2;

             
             
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  

             
             
             
             
            result = prod0 * inverse;
            return result;
        }
    }

     
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

     
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

         
         
         
         
         
         
         
         
         
         
        uint256 result = 1 << (log2(a) >> 1);

         
         
         
         
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

     
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

     
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

     
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

     
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

     
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

     
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

     
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

 


pragma solidity ^0.8.4;


library StringBuilderLib {
	bytes16 private constant _SYMBOLS = "0123456789";

    struct StringBuilder {
		bytes buf;
		uint256 len;
	}

	function newStringBuilder(uint256 n) internal pure returns (StringBuilder memory) {
		return StringBuilder({
			buf: new bytes(n),
			len: 0
		});
	}

	function writeString(
		StringBuilder memory stringBuilder, 
		string memory s
	) internal pure {
		writeBytes(stringBuilder, bytes(s));
	}

	function writeBytes(
		StringBuilder memory stringBuilder, 
		bytes memory b
	) internal pure {
		uint256 len = stringBuilder.len;
		for (uint256 i = 0; i < b.length; i++) {
			stringBuilder.buf[len + i] = b[i];
		}
		stringBuilder.len += b.length;
	}

	function writeChar(
		StringBuilder memory stringBuilder, 
		string memory s
	) internal pure {
		stringBuilder.buf[stringBuilder.len] = bytes(s)[0];
		stringBuilder.len++;
	}

	 
	function writeFixed(
		StringBuilder memory stringBuilder, 
		uint256 value
	) internal pure {
		unchecked {
			bytes memory buf = stringBuilder.buf;
			uint256 len = stringBuilder.len;

			 
            uint256 length = Math.log10(value) + 1 + 1; 
			uint256 i = 0;
            uint256 ptr;
            
            assembly {
                ptr := add(buf, add(add(len, 32), length))
            }
            while (true) {
				 
				if (i == 1) {
					ptr--;
					
                	assembly {
                    	mstore8(ptr, byte(0, "."))
                	}
				}
                ptr--;
                
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
				i += 1;
            }
			stringBuilder.len += length;
			 
			while (true) {
				bytes1 char = stringBuilder.buf[stringBuilder.len - 1];
				if (char == ".") {
					stringBuilder.len--;
					break;
				}
				if (char != "0") {
					break;
				}
				stringBuilder.len--;
			}
        }
	}

	function trimOne(StringBuilder memory stringBuilder) internal pure {
		stringBuilder.len--;
	}

	function toBytes(
		StringBuilder memory stringBuilder
	) internal pure returns (bytes memory) {
		bytes memory buf = stringBuilder.buf;
		uint256 len = stringBuilder.len;
        
		assembly {
			mstore(buf, len)
		}
		return buf;
	}

	function toString(
		StringBuilder memory stringBuilder
	) internal pure returns (string memory) {
		return string(toBytes(stringBuilder));
	}
}
 


pragma solidity ^0.8.4;


library PathLib {
    function decodePath(
		StringBuilderLib.StringBuilder memory stringBuilder, 
		bytes memory path
	) internal pure {
        uint256 i = 0;
        while (i < path.length) {
            uint8 u = uint8(path[i]);
            if (u == 128) {
				StringBuilderLib.writeChar(stringBuilder, "M");
                i++;
            } else if (u == 129) {
				StringBuilderLib.writeChar(stringBuilder, "C");
                i++;
            } else if (u == 130) {
				StringBuilderLib.writeChar(stringBuilder, "Z");
                i++;
            } else {
				StringBuilderLib.writeFixed(stringBuilder, readUint16(path, i));
				i += 2;

				StringBuilderLib.writeChar(stringBuilder, ",");
				
				StringBuilderLib.writeFixed(stringBuilder, readUint16(path, i));
                i += 2;
            }
			StringBuilderLib.writeChar(stringBuilder, " ");
        }
		StringBuilderLib.trimOne(stringBuilder);
    }

    function readUint16(bytes memory b, uint start) private pure returns (uint16) {
        uint16 x;
        assembly {
            x := mload(add(b, add(0x02, start)))
        }
        return x;
    }
}
 


 

pragma solidity ^0.8.0;


 
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

     
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

     
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

     
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

     
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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

 




pragma solidity ^0.8.4;







contract MetadataGenerator is Ownable {
	struct Color {
		string name;
		string value;
	}

    struct Body {
        string name;
        bytes path;
		uint256 destlen;
    }

	struct Face {
        string name;
        bytes path;
		uint256 destlen;
    }

    mapping(uint8 => Color) public colors;
    mapping(uint8 => Body) public bodies;
    mapping(uint8 => Face) public faces;
	
	string public externalUrlPrefix;

	constructor(string memory _externalUrlPrefix) {
		externalUrlPrefix = _externalUrlPrefix;
	}

	function setColors(
		uint8[] calldata ids,
		string[] calldata names,
		string[] calldata values
	) external onlyOwner {
		for (uint256 i = 0; i < ids.length; i++) {
			colors[ids[i]] = Color({
				name: names[i], 
				value: values[i]
			});
		}
	}

    function setBodies(
		uint8[] calldata ids,
		string[] calldata names,
		bytes[] calldata paths,
		uint256[] calldata destlens
	) external onlyOwner {
		for (uint i = 0; i < ids.length; i++) {
			bodies[ids[i]] = Body({ 
				name: names[i], 
				path: paths[i],
				destlen: destlens[i]
			});
		}
    }

    function setFaces(
		uint8[] calldata ids,
		string[] calldata names,
		bytes[] calldata paths,
		uint256[] calldata destlens
	) external onlyOwner {
		for (uint i = 0; i < ids.length; i++) {
			faces[ids[i]] = Face({ 
				name: names[i], 
				path: paths[i],
				destlen: destlens[i]
			});
		}
    }

	function setExternalUrlPrefix(string memory _externalUrlPrefix) external onlyOwner {
		externalUrlPrefix = _externalUrlPrefix;
	}

	function generateMetadata(uint256 tokenId) external view returns (string memory) {
		(uint8 colorId, uint8 bodyId, uint8 faceId) = splitTokenId(tokenId);
		
		Color memory color = colors[colorId];
		Body memory body = bodies[bodyId];
		Face memory face = faces[faceId];

		 
		uint256 buffSize = 341 + body.destlen + face.destlen;
		StringBuilderLib.StringBuilder memory stringBuilder = StringBuilderLib.newStringBuilder(buffSize);
		generateSvg(stringBuilder, color.value, body.path, face.path);
		bytes memory svg = StringBuilderLib.toBytes(stringBuilder);

		string memory tokenIdString = Strings.toString(tokenId);
		
		return string(abi.encodePacked("data:application/json;base64,", Base64.encode(abi.encodePacked(
			"{\"image\":\"data:image/svg+xml;base64,", Base64.encode(svg),
			"\",\"name\":\"Buddy #", tokenIdString,
			"\",\"external_url\":\"", externalUrlPrefix, tokenIdString,
			"\",\"attributes\":[{\"trait_type\":\"Color\",\"value\":\"", color.name, 
			"\"},{\"trait_type\":\"Body\",\"value\":\"", body.name, 
			"\"},{\"trait_type\":\"Face\",\"value\":\"", face.name, 
			"\"}]}"
		))));
	}

	function splitTokenId(uint256 tokenId) private pure returns (uint8, uint8, uint8) {
		require(tokenId < 1000);
		uint256 color = tokenId / 100;
		tokenId = tokenId - (color * 100);
		uint256 body = tokenId / 10;
		uint256 face = tokenId - (body * 10);
		return (uint8(color), uint8(body), uint8(face));
	}

	function generateSvg(
		StringBuilderLib.StringBuilder memory stringBuilder,
		string memory _color,
		bytes memory _body,
		bytes memory _face
	) private pure {
		StringBuilderLib.writeString(stringBuilder, "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><svg width=\"1e3\" height=\"1e3\" viewBox=\"0 0 1e3 1e3\" version=\"1.1\" id=\"svg115\" xml:space=\"preserve\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:svg=\"http://www.w3.org/2000/svg\">");
       	writeSvgPath(stringBuilder, "body", _color, _body);
       	writeSvgPath(stringBuilder, "face", "000000", _face);
       	StringBuilderLib.writeString(stringBuilder, "</svg>");
	}

	function writeSvgPath(
		StringBuilderLib.StringBuilder memory stringBuilder,
		string memory id,
		string memory color,
		bytes memory path
	) private pure {
		StringBuilderLib.writeString(stringBuilder, "<path id=\"");
		StringBuilderLib.writeString(stringBuilder, id);
		StringBuilderLib.writeString(stringBuilder, "\" d=\"");
		PathLib.decodePath(stringBuilder, path);
		StringBuilderLib.writeString(stringBuilder, "\" fill=\"#");
		StringBuilderLib.writeString(stringBuilder, color);
		StringBuilderLib.writeString(stringBuilder, "\" stroke=\"#");
		StringBuilderLib.writeString(stringBuilder, color);
		StringBuilderLib.writeString(stringBuilder, "\" />");
	}
}