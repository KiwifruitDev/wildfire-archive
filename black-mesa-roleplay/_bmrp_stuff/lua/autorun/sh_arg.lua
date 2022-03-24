// Wildfire Black Mesa Roleplay
// File description: BMRP shared alternative reality game script
// Copyright (c) 2022 KiwifruitDev
// Licensed under the MIT License.
//*********************************************************************************************
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//*********************************************************************************************
// BASE FILE HEADER DO NOT MODIFY!! //
local ent = FindMetaTable("Entity") //
local ply = FindMetaTable("Player") //
local vec = FindMetaTable("Vector") //
// ================================ //

// Global variable to store everything from here.
BMRP_ARG = {}

-- enumerables
BMRP_ARG.ENUMS = {}
BMRP_ARG.ENUMS.ARG_FILE_GENERIC = 1
BMRP_ARG.ENUMS.ARG_FILE_FOLDER = 2
BMRP_ARG.ENUMS.ARG_FILE_IMAGE = 3
BMRP_ARG.ENUMS.ARG_FILE_SOUND = 4
BMRP_ARG.ENUMS.ARG_FILE_TEXT = 5

-- login data
BMRP_ARG.LOGINS = {
    ["root"] = {
        startdirectory = {
            "home",
            "root",
        }, -- /home/root
        files = { -- files start at the location "/"
            {
                type = BMRP_ARG.ENUMS.ARG_FILE_FOLDER,
                name = "home",
                contents = {
                    {
                        type = BMRP_ARG.ENUMS.ARG_FILE_FOLDER,
                        name = "root",
                        contents = {
                            {
                                type = BMRP_ARG.ENUMS.ARG_FILE_FOLDER,
                                name = ".local",
                                contents = {
                                    {
                                        type = BMRP_ARG.ENUMS.ARG_FILE_FOLDER,
                                        name = "share",
                                        contents = {
                                            {
                                                type = BMRP_ARG.ENUMS.ARG_FILE_FOLDER,
                                                name = "trash",
                                                contents = {
                                                    {
                                                        type = BMRP_ARG.ENUMS.ARG_FILE_TEXT,
                                                        name = "intercoms.txt",
                                                        contents = [[MIME-Version 1.0
Received: by fe80::6d37:7728:6707:c751 with HTTP; Thu, 15 Dec 200- 17:23:16 -0600 (MST)
Date: Thu, 15 Dec 200- 17:23:16 -0600 (MST)
Delivered-To: root@[192.168.1.255]
Message-ID: <d377195c-9531-4b7d-9eec-bec81b31d405@[192.168.1.255]>
Subject: Regarding the installation of intercoms
From: ckiwano@[192.168.1.255]
To: root@[192.168.1.255]
Content-Type: text/plain; charset="UTF-8"

Good evening Administrator,

I am concerned over the installation of intercoms. I have a few questions.
One that I may ask is, why was I assigned IT support?
This was not communicated to me, and I have no business working in that field.
After all, I am a student and I am not allowed to use the intercoms.
Please let me know how I should proceed.

Regards,
Dr. Carlos Kiwano
Head of Networking
Black Mesa Research Facility]],
                                                    }
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                            {
                                type = BMRP_ARG.ENUMS.ARG_FILE_FOLDER,
                                name = "classified",
                                contents = {},
                            },
                        },
                    },
                },
            },
            {

            }
        },
    },
    ["administrator"] = {
        alias = "root",
    },
    ["admin"] = {
        alias = "root",
    },
    ["ckiwano"] = {},
}

BMRP_ARG.CASSETTES = {
    [1] = { // test cassette
        sound = "https://cdn.discordapp.com/attachments/864102322971607040/909919752959443035/Jingle_Bells_Instrumental.mp3",
        text = "test cassette",
        length = 10,
    },
}
